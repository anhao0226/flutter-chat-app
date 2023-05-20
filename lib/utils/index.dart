import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:desktop_app/models/ws_message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'initialization.dart';

const Uuid uuid = Uuid();

// imageSize
Future<ui.Image> imageSize(String filepath) async {
  Image image = Image.file(File(filepath));
  Completer<ui.Image> completer = Completer<ui.Image>();
  image.image
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((image, synchronousCall) {
    completer.complete(image.image);
  }));
  return completer.future;
}

// logger
final logger = Logger(printer: PrettyPrinter());

final localCacheDirectoryMap = <MessageType, Directory>{
  MessageType.voice: Initialization.voiceSaveDir,
  MessageType.picture: Initialization.pictureSaveDir,
  MessageType.video: Initialization.voiceSaveDir,
};

String generatePath(Directory rootDir, String url) {
  var suffixIndex = url.lastIndexOf(".") + 1;
  return path.join(rootDir.path,
      '${DateTime.now().millisecondsSinceEpoch}.${url.substring(suffixIndex)}');
}

// path join
String combinePath(Directory rootDir, String url) {
  var lastCharacterIndex = url.lastIndexOf("/") + 1;
  return path.join(rootDir.path, url.substring(lastCharacterIndex));
}

// zerofill
String zerofill(int value) {
  return value < 10 ? '0$value' : '$value';
}

// dateFormat
String dateFormat(DateTime value) {
  var curr = DateTime.now();
  if (value.isBefore(curr.dayStartTime())) {
    return '${value.year}/${value.month}/${value.day}';
  }
  return '${zerofill(value.hour)}:${zerofill(value.minute)}';
}

//
extension Date on DateTime {
  DateTime dayStartTime() {
    return DateTime(year, month, day);
  }

  DateTime dayEndTime() {
    return DateTime(year, month, day + 1);
  }
}
