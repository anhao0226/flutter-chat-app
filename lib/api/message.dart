import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/utils/index.dart';

import '../utils/dio_instance.dart';

Future<ResponseData> handleSendMessage({
  required String text,
  required String sender,
  required MessageType msgType,
  required List<String> receivers,
  Map<String, dynamic>? extend,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
}) async {
  var data = <String, dynamic>{};
  data["text"] = text;

  switch (msgType) {
    case MessageType.file:
    case MessageType.voice:
    case MessageType.video:
    case MessageType.picture:
    case MessageType.location:
      data["text"] = await MultipartFile.fromFile(text);
      break;
    default:
  }

  data["sender"] = sender;
  data["receivers"] = receivers.join(",");
  data["type"] = msgType.value;
  data["sendTime"] = DateTime.now().millisecondsSinceEpoch;
  if (extend != null) {
    data["extend"] = jsonEncode(extend);
  }
  try {
    FormData formData = FormData.fromMap(data);
    Response response = await dioInstance.post(
      "/message/send",
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
