import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';

import '../utils/index.dart';

class ClientState {
  WSClient? wsClient;

  int unreadMsgNum = 0;
  late String lastMessageContent;
  late DateTime lastMessageTime;

  ClientState(
    this.unreadMsgNum,
    this.lastMessageContent,
  ) : lastMessageTime = DateTime.now();

  ClientState.formCache(dynamic json) {
    unreadMsgNum = json["unreadMsgNum"];
    lastMessageContent = json["lastMessageContent"];
    lastMessageTime =
        DateTime.fromMillisecondsSinceEpoch(json["lastMessageTime"]);
  }

  void updateValue(WSMessage message) {
    unreadMsgNum++;
    lastMessageContent =
        message.type == MessageType.text ? message.text : message.type.tag;
    logger.i(message.timestamp);
    lastMessageTime = message.sendTime;
  }

  ClientState.copyWith(WSMessage message) {
    unreadMsgNum = 1;
    lastMessageContent =
        message.type == MessageType.text ? message.text : message.type.tag;
    lastMessageTime = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data["unreadMsgNum"] = unreadMsgNum;
    data["lastMessageContent"] = lastMessageContent;
    data["lastMessageTime"] = lastMessageTime.millisecondsSinceEpoch;
    return data;
  }
}
