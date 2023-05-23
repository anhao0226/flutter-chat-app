import 'dart:convert';

import 'package:flutter_chat_app/models/client_state.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/utils/hive.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/notification.dart';
import 'package:flutter_chat_app/views/client_list/my_home_page.dart';
import 'package:flutter/cupertino.dart';

import '../models/ws_client_model.dart';
import '../utils/dio_instance.dart';
import 'home_state_management.dart';

class WSClientManagement extends ChangeNotifier {
  factory WSClientManagement() {
    _instance ??= WSClientManagement._();
    return _instance!;
  }

  WSClientManagement._() {
    loadCacheClients();
  }

  static WSClientManagement? _instance;

  static WSClientManagement get instance => WSClientManagement();

  final _clients = <WSClient>[];
  final _clientStates = <WSClient>[];
  final _clientsMap = <String, WSClient>{};
  final _clientStateMap = <String, int>{};
  WSClient? _hasChatState;

  //
  List<WSClient> get clients => _clients;

  List<WSClient> get clientStates => _clientStates;

  void removeItem(WSClient client) {
    _clients.remove(client);
    //
    if (_clientStateMap.containsKey(client.uid)) {
      _clientStates.remove(client);
      _clientStateMap.remove(client.uid);
    }
    HiveUtils.instance.clients.delete(client.uid);
    // clear chat data
    notifyListeners();
  }

  void _addClient(WSClient client, bool save) {
    _clients.add(client);
    _clientsMap[client.uid] = client;
    _moveToTop(client);
    if (save) _saveClientToCache(client);
  }

  void _moveToTop(WSClient client) {
    if (_clients.length == 1 || _clients[0] == client) return;
    if (_clients.remove(client)) {
      _clients.insert(0, client);
      notifyListeners();
    }
  }

  Future<void> loadCacheClients() async {
    _clients.clear();
    var keys = HiveUtils.instance.clients.keys;
    for (var clientId in keys) {
      final client = await _getClientCache(clientId);
      if (client != null && !_checkSelf(client.uid)) {
        if (client.state != null) {
          _clientStates.add(client);
          _clientStateMap[client.uid] = 0;
        }
        _addClient(client, false);
      }
    }
    notifyListeners();
  }

  Future<bool> fetchClients() async {
    try {
      var message = await fetchClientList();
      for (var client in message.data) {
        if (_clientsMap.containsKey(client.uid)) {
          _clientsMap[client.uid]!.online = true;
          _moveToTop(_clientsMap[client.uid]!);
        } else if (!_checkSelf(client.uid)) {
          _addClient(client, true);
        }
      }
      notifyListeners();
    } catch (err) {
      logger.e(err);
      return Future.error(err);
    }
    return true;
  }

  bool _checkSelf(String value) {
    return Initialization.client != null && value == Initialization.client!.uid;
  }

  // consumer message
  void handleMessage(WSMessage message) {
    switch (message.type) {
      case MessageType.text:
      case MessageType.voice:
      case MessageType.video:
      case MessageType.picture:
      case MessageType.file:
        _handleChatMessage(message);
        return;
      case MessageType.online:
      case MessageType.offline:
        _handleClientStatusChanged(message);
        return;
      default:
    }
  }

  void _handleClientStatusChanged(WSMessage message) async {
    if (_clientsMap.containsKey(message.sender)) {
      if (message.type == MessageType.online) {
        _clientsMap[message.sender]!.online = true;
        _moveToTop(_clientsMap[message.sender]!);
      } else {
        _clientsMap[message.sender]!.online = false;
      }
    } else if (message.type == MessageType.online &&
        !_checkSelf(message.sender)) {
      WSClient client = WSClient.formServer(message.extend);
      _addClient(client, true);
    }
    HomeStateManagement.instance.showSegmentDot(Segment.online);
    notifyListeners();
  }

  void _handleChatMessage(WSMessage message) {
    if (_clientsMap.containsKey(message.sender)) {
      var client = _clientsMap[message.sender]!;

      if (_hasChatState == null) {
        if (client.state == null) {
          client.state = ClientState.copyWith(message);
          client.state?.wsClient = client;
          _clientStateMap[client.uid] = 0;
          _clientStates.add(client);
        } else if (_clientStateMap.containsKey(message.sender)) {
          client.state!.updateValue(message);
        }
      } else if (_hasChatState!.uid != message.sender) {
        // update client state
        client.state!.updateValue(message);
        // 发送系统通知(用户处于对话框中且新的消息发送人为其他用户)
        var payLoad = jsonEncode(_clientsMap[message.sender]);
        var body = message.text;
        if (message.type != MessageType.text) body = message.type.tag;
        var title = _clientsMap[message.sender]!.nickname;
        _pushSysNotification(title, body, payLoad);
      }
      _saveClientToCache(client);
    } else {}
    HomeStateManagement.instance.showSegmentDot(Segment.message);
    notifyListeners();
  }

  void _pushSysNotification(String title, String body, String payLoad) {
    NotificationService.showNotification(
        title: title, body: body, payLoad: payLoad);
  }

  void clearClientState(List<WSClient> values) {
    for (var element in values) {
      element.state = null;
      _clientStates.remove(element);
      _clientStateMap.remove(element.uid);
      _saveClientToCache(element);
    }
    notifyListeners();
  }

  Future<WSClient?> _getClientCache(String key) async {
    return await HiveUtils.instance.clients.get(key);
  }

  void _saveClientToCache(WSClient client) {
    HiveUtils.instance.clients.put(client.uid, client);
  }

  enterChatStatus(WSClient client) {
    _hasChatState = client;
    if (_clientsMap.containsKey(client.uid)) {
      client.state?.unreadMsgNum = 0;
      _saveClientToCache(client);
      notifyListeners();
    }
  }

  //
  exitChatStatus() => _hasChatState = null;
}
