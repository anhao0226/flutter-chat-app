import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_chat_app/database/chat_db_utils.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';

class WSUtil {
  factory WSUtil() {
    _instance ??= WSUtil._();
    _streamController ??= StreamController.broadcast();
    return _instance!;
  }

  WSUtil._();

  static WSUtil? _instance;

  static WSUtil get instance => WSUtil();

  static IOWebSocketChannel? _webSocketChannel;

  static StreamController<WSMessage>? _streamController;

  Stream<WSMessage> get onData => _streamController!.stream;

  Stream<WSMessage> onSender(String sender) {
    return onData.where((event) => event.sender == sender);
  }

  final _connectivity = ValueNotifier<bool>(false);

  ValueNotifier<bool> get connectivity => _connectivity;

  close() => _webSocketChannel!.sink.close();

  Future<bool> initWebSocket({
    required int port,
    required String host,
    required WSClient client,
  }) async {
    if (connectivity.value) return false;
    try {
      // 初始化连接参数
      var uri = _initUrl(port: port, host: host, client: client);
      WebSocket socket = await WebSocket.connect(uri.toString());
      // 设置心跳包发送间隔
      socket.pingInterval = const Duration(seconds: 20);
      _webSocketChannel = IOWebSocketChannel(socket);
      _webSocketChannel?.stream.listen(_handleOnData,
          onDone: _handleConnDone, onError: _handleConnError);
      connectivity.value = true;
      return true;
    } catch (e) {
      logger.e(e.toString());
      connectivity.value = false;
      return Future.error(e);
    }
  }

  Uri _initUrl({
    required int port,
    required String host,
    required WSClient client,
  }) {
    var queryParameters = <String, dynamic>{};
    queryParameters["nickname"] = client.nickname;
    queryParameters["avatarUrl"] = client.avatarUrl;
    queryParameters["uid"] = client.uid;

    return Uri(
      scheme: "ws",
      host: host,
      port: port,
      queryParameters: queryParameters,
      path: "/ws",
    );
  }

  //
  void _handleConnDone() {
    connectivity.value = false;
    _streamController!.sink
        .addError("The websocket connection has been disconnected");
  }

  //
  void _handleConnError(dynamic err) {
    connectivity.value = false;
    _streamController!.sink.addError(err);
  }

  //new message
  void _handleOnData(dynamic data) async {
    logger.i(data);
    Map<String, dynamic> toJson = jsonDecode(data);
    var message = WSMessage.formServer(toJson);
    switch (message.type) {
      case MessageType.text:
        break;
      case MessageType.file:
      case MessageType.voice:
      case MessageType.video:
      case MessageType.picture:
        message.filepath = _savePath(message.type, message.text);
        message.status = MessageStatus.download;
        break;
      case MessageType.online:
      case MessageType.offline:
        break;
      default:
        break;
    }

    message.id = await _saveToDatabase(message);
    _streamController!.sink.add(message);
  }

  // send message
  Future<WSMessage> messageWrap(
    String text,
    String receiver,
    MessageType msgType,
    Map<String, dynamic>? extend,
  ) async {
    var message = WSMessage(
      text: text,
      type: msgType,
      receiver: receiver,
      sender: Initialization.client!.uid,
    );
    // 更改为待发送状态
    message.status = MessageStatus.send;
    // 处理对应类型数据
    switch (msgType) {
      case MessageType.file:
      case MessageType.voice:
      case MessageType.video:
      case MessageType.picture:
        message.extend = extend;
        message.filepath = _savePath(msgType, text);
        message.id = await _saveToDatabase(message);
        await File(text).copy(message.filepath!);
        break;
      case MessageType.location:
        message.extend = extend;
        message.text = extend!['snapshot']!;
        // 保存到图片文件夹
        message.filepath = _savePath(MessageType.picture, text);
        message.id = await _saveToDatabase(message);
        break;
      case MessageType.text:
        message.id = await _saveToDatabase(message);
        break;
      default:
    }
    return message;
  }

  String _savePath(MessageType type, String filepath) {
    return generatePath(localCacheDirectoryMap[type]!, filepath);
  }

  // 保存本地数据库
  Future<int> _saveToDatabase(WSMessage message) async {
    return ChatDatabase.insertRecord(message);
  }
}
