import 'dart:async';

import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/chat_db_utils.dart';
import '../utils/websocket.dart';

enum LoadingState { loading, idle, hide }

class ChatProvider extends ChangeNotifier {
  //
  late WSClient _wsClient;

  WSClient get wsClient => _wsClient;

  final _neededUploadItems = <int>[];

  bool _isDisposed = false;
  final cacheMessage = <WSMessage>[];
  List<WSMessage> messages = [];

  VoidCallback? _onNewMessage;
  late StreamSubscription _subscription;

  bool isOnline = false;
  bool isLoading = true;
  bool showStatusBar = false;
  LoadingState loadingState = LoadingState.idle;

  ChatProvider(WSClient client) {
    _wsClient = client;
    isOnline = _wsClient.online;
    showStatusBar = !isOnline;
    _subscription =
        WSUtil.instance.onSender(client.uid).listen(_handleNewWsMessage);
    handleLoadCacheMessage();
  }

  bool neededUpload(int id) {
    return _neededUploadItems.remove(id);
  }

  void hiddenStatusBar() {
    showStatusBar = false;
    notifyListeners();
  }

  Future<void> handleLoadCacheMessage() async {
    var records = await ChatDatabase.queryRecords(
      receiver: _wsClient.uid,
      sender: Initialization.client!.uid,
    );
    messages.addAll(records.reversed.toList());
    loadingState = records.length < 15 ? LoadingState.hide : LoadingState.idle;
    isLoading = false;
    notifyListeners();
    if (_onNewMessage != null) _onNewMessage!();
  }

  Future<void> handleMoreData() async {
    if (loadingState == LoadingState.hide) return;
    loadingState = LoadingState.loading;
    late int endId;
    if (cacheMessage.isNotEmpty) {
      endId = cacheMessage.last.id;
    } else if (messages.isNotEmpty) {
      endId = messages.first.id;
    }

    var records = await ChatDatabase.queryRecords(
      limit: 8,
      endId: endId,
      sender: Initialization.client!.uid,
      receiver: _wsClient.uid,
    );

    loadingState = records.length < 8 ? LoadingState.hide : LoadingState.idle;
    cacheMessage.addAll(records);
    notifyListeners();
  }

  void onNewMessage(VoidCallback callback) {
    _onNewMessage = callback;
  }

  // _handleWsData
  void _handleNewWsMessage(WSMessage msg) async {
    switch (msg.type) {
      case MessageType.online:
      case MessageType.offline:
        isOnline = msg.type == MessageType.online;
        showStatusBar = !isOnline;
        break;
      default:
        messages.add(msg);
        break;
    }
    notifyListeners();
    if (_onNewMessage != null) _onNewMessage!();
  }

  // send message
  void sendMessage({
    required String text,
    required MessageType type,
    Map<String, dynamic>? extend,
  }) async {
    var message =
        await WSUtil.instance.messageWrap(text, _wsClient.uid, type, extend);
    logger.i(message.text);
    messages.add(message);
    notifyListeners();
    if (_onNewMessage != null) _onNewMessage!();
  }

  Future<bool> deleteRecords(List<WSMessage> values) async {
    logger.i(values);
    for (var msg in values) {
      await ChatDatabase.deleteRow(msg);
      if (msg.id >= messages.first.id) {
        messages.remove(msg);
      } else {
        cacheMessage.remove(msg);
      }
    }
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }
}
