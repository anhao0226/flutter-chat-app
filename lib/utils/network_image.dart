// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:desktop_app/utils/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class CacheNetworkImage extends ImageProvider<CacheNetworkImage> {
  const CacheNetworkImage(this.url, this.file,
      {this.scale = 1.0, this.headers});

  final String url;

  final double scale;

  final File file;

  final Map<String, String>? headers;

  @override
  Future<CacheNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(CacheNetworkImage key, DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.

    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, null, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CacheNetworkImage>('Image key', key),
        ErrorDescription('Path: ${file.path}'),
      ],
    );
  }

  @override
  ImageStreamCompleter loadBuffer(
      CacheNetworkImage key, DecoderBufferCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    logger.i("loadBuffer");

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode, null),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CacheNetworkImage>('Image key', key),
        ErrorDescription('Path: ${file.path}'),
      ],
    );
  }

  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) {
        client = debugNetworkImageHttpClientProvider!();
      }
      return true;
    }());
    return client;
  }

  Future<ui.Codec> _loadAsync(
    CacheNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderBufferCallback? decode,
    DecoderCallback? decodeDeprecated,
  ) async {
    try {
      assert(key == this);
      // Handle file cache
      if (await file.exists()) {
        final int lengthInBytes = await file.length();
        if (lengthInBytes == 0) {
          // The file may become available later.
          PaintingBinding.instance.imageCache.evict(key);
          throw StateError('$file is empty and cannot be loaded as an image.');
        }
        if (decode != null) {
          if (file.runtimeType == File) {
            return decode(await ui.ImmutableBuffer.fromFilePath(file.path));
          }

          final Uint8List bytes = await file.readAsBytes();

          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: bytes.length,
            expectedTotalBytes: bytes.length,
          ));

          return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
        }
        return decodeDeprecated!(await file.readAsBytes());
      } else {
        // create a new file
        await file.create();
      }

      // Handle network image
      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        // The network may be only temporarily unavailable, or the file will be
        // added on the server later. Avoid having future calls to resolve
        // fail to check the network again.
        await response.drain<List<int>>(<int>[]);
        throw NetworkImageLoadException(
            statusCode: response.statusCode, uri: resolved);
      }
      //
      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }

      // Save bytes to local file
      await file.writeAsBytes(bytes);

      if (decode != null) {
        final ui.ImmutableBuffer buffer =
            await ui.ImmutableBuffer.fromUint8List(bytes);
        return decode(buffer);
      } else {
        assert(decodeDeprecated != null);
        return decodeDeprecated!(bytes);
      }
    } catch (e) {
      logger.i(e);
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is CacheNetworkImage &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(file.path, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CacheNetworkImage')}("$url", scale: $scale)';
}
