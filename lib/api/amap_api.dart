import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter_chat_app/models/amap/amap_poi.dart' as amap;
import 'package:flutter_chat_app/utils/index.dart';

class AMapDio {
  static Dio _initDio() {
    _instance = Dio(
      BaseOptions(
        baseUrl: "https://restapi.amap.com/v3",
        queryParameters: {"key": "022c545d454d94f493f7d06c9b1d89d3"},
      ),
    );
    _initInterceptors();
    return _instance!;
  }

  static Dio _getDioInstance() {
    _instance ??= _initDio();
    return _instance!;
  }

  static Dio? _instance;

  static Dio get instance => _getDioInstance();

  static final _memCacheMap = <Uri, Response>{};

  static void _initInterceptors() {
    _instance!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.i(_memCacheMap.containsKey(options.uri));
          if (_memCacheMap.containsKey(options.uri)) {
            return handler.resolve(_memCacheMap[options.uri]!);
          }
          return handler.next(options);
        },
        onResponse: (options, handler) {
          if (!_memCacheMap.containsKey(options.requestOptions.uri)) {
            _memCacheMap[options.requestOptions.uri] = options;
          }
          handler.next(options);
        },
      ),
    );
  }
}

//
Future<List<amap.AMapPoi>> fetchPlaceAround({
  required LatLng latLng,
  int offset = 10,
}) async {
  var queryParameters = <String, dynamic>{};
  queryParameters["location"] = (latLng.toJson() as List<double>).join(",");
  queryParameters["offset"] = offset;

  try {
    Response response = await AMapDio.instance
        .get("/place/around", queryParameters: queryParameters);
    var responseData = response.data;
    var result = <amap.AMapPoi>[];
    logger.i(responseData);
    if (responseData['info'] == 'OK' && responseData['status'] == '1') {
      var pois = responseData['pois'] as List;
      for (var element in pois) {
        result.add(amap.AMapPoi.fromJson(element));
      }
    }
    return result;
  } catch (err) {
    return Future.error(err);
  }
}
