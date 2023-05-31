import 'package:dio/dio.dart';

late Dio dioInstance;

void initDio() {
  dioInstance = Dio(
    BaseOptions(
      queryParameters: {
        "key": "PPPPPPPPPPPPPPPPPP"
      }
    )
  );
  dioInstance.interceptors.add(
    InterceptorsWrapper(onRequest: (options, handler) {
      print('');
      print(options.path);
      print(options.queryParameters);
      return handler.resolve(
        Response(requestOptions: options, data: 'fake data'),
      );
    }),
  );
}

void _fetchResult() async {
  var res = await dioInstance.get(
    "/test",
    queryParameters: {"A": "BBB"},
  );
  print(res);
}

void main() {
  initDio();
  _fetchResult();
}
