import 'dart:convert';

import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_app/utils/initialization.dart';

var dioInstance = Dio(BaseOptions(
  baseUrl: "http://${Initialization.address}",
));

class ResponseData {
  late int code;
  late bool success;
  late String message;
  late Map<String, dynamic> data;

  ResponseData.formJson(dynamic json) {
    code = json["code"];
    success = json["success"];
    message = json["message"];
    data = json["data"];
  }
}

// 下载文件
Future<Object> handleDownloadFile(
  String url,
  String savePath, {
  ProgressCallback? onSendProgress,
  CancelToken? cancelToken,
}) async {
  try {
    await dioInstance.download(
      url,
      savePath,
      onReceiveProgress: onSendProgress,
      cancelToken: cancelToken,
    );
    return true;
  } catch (e) {
    return Future.error(e);
  }
}

// 上传文件
Future<ResponseData> handleUploadFile(
  String sender,
  List<String> receivers,
  String filepath,
  int msgType, {
  CancelToken? cancelToken,
  Map<String, dynamic>? extend,
  ProgressCallback? onSendProgress,
}) async {
  var data = <String, dynamic>{};
  data["file"] = await MultipartFile.fromFile(filepath);
  data["sender"] = sender;
  data["receivers"] = receivers.join(",");
  data["type"] = msgType;
  data["sendTime"] = DateTime.now().millisecondsSinceEpoch;
  if (extend != null) {
    data["extend"] = jsonEncode(extend);
  }
  try {
    FormData formData = FormData.fromMap(data);
    Response response = await dioInstance.post(
      "/file/upload",
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
    var responseData = response.data;
    return ResponseData.formJson(responseData);
  } catch (err) {
    return Future.error(err);
  }
}

class WsClientMessage {
  final List<WSClient> data;
  final int timestamp;

  WsClientMessage(this.data, this.timestamp);
}

// fetchUsers
Future<WsClientMessage> fetchClientList() async {
  late WsClientMessage result;
  try {
    var response = await dioInstance.get("/users");
    Map<String, dynamic> responseData = response.data;
    if (responseData["code"] == 200 && responseData["data"] is List) {
      var temp = <WSClient>[];
      for (var element in responseData["data"]) {
        temp.add(WSClient.formServer(element));
      }
      result = WsClientMessage(temp, responseData["timestamp"]);
    } else {
      return Future.error(responseData["message"]);
    }
  } catch (e) {
    return Future.error(e);
  }
  return result;
}

class ServerIconData {
  late String src;
  late String name;

  ServerIconData(this.name, this.src);
}

// fetchUsers
Future<List<ServerIconData>> fetchIcons({
  Dio? instance,
}) async {
  try {
    late Response response;
    if (instance != null) {
      response = await instance.get("/file/icons");
    } else {
      response = await dioInstance.get("/file/icons");
    }
    Map<String, dynamic> responseData = response.data;
    if (responseData["code"] == 200 && responseData["data"] is List) {
      var result = <ServerIconData>[];
      for (var element in responseData["data"]) {
        result.add(ServerIconData(element["name"], element["src"]));
      }
      return result;
    } else {
      return Future.error(responseData["message"]);
    }
  } catch (e) {
    return Future.error(e);
  }
}
