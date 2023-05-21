// WebSocketClient

import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';

import 'client_state.dart';

class WSClient {
  late String uid;
  late String nickname;
  late String avatarUrl;
  late String avatarPath;
  late bool online;

  ClientState? state;

  WSClient({
    required this.uid,
    required this.nickname,
    required this.avatarUrl,
  }) {
    avatarPath = _savePath(avatarUrl);
  }

  WSClient.formServer(dynamic json) {
    online = true;
    uid = json['uid'];
    nickname = json['nickname'];
    avatarUrl = json["avatar_url"];
    avatarPath = generatePath(Initialization.avatarDir, avatarUrl);
  }

  WSClient.formCache(dynamic json) {
    online = false;
    uid = json['uid'];
    nickname = json['nickname'];
    avatarUrl = json["avatarUrl"] ?? "";
    avatarPath = json["avatarPath"] ?? "";
    if (json["state"] != null) {
      state = ClientState.formCache(json["state"]);
    }
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data["uid"] = uid;
    data["nickname"] = nickname;
    data["avatarUrl"] = avatarUrl;
    data["avatarPath"] = avatarPath;
    data["state"] = state?.toJson();
    return data;
  }

  String _savePath(String url) {
    return generatePath(Initialization.avatarDir, url);
  }

  @override
  bool operator ==(Object other) {
    return uid == (other as WSClient).uid;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => uid.hashCode;
}
