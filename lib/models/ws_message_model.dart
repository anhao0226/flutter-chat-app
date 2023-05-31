import 'dart:convert';

enum MessageType {
  text(0, ""),
  voice(1, "[voice]"),
  video(2, "[video]"),
  picture(3, "[picture]"),
  online(4, "[online]"),
  offline(5, "[offline]"),
  file(6, "[file]"),
  location(7, "[file]");

  const MessageType(this.value, this.tag);

  final int value;
  final String tag;
}

enum MessageStatus {
  normal(0),
  unread(1),
  download(2),
  upload(3),
  error(4),
  send(5);

  const MessageStatus(this.value);

  final int value;
}

class WSMessage {
  late int id;
  late String text;
  late String sender;
  late String receiver;
  late MessageType type;
  late DateTime sendTime;
  late int timestamp;
  Map<String, dynamic>? extend;
  String? filepath;
  MessageStatus status = MessageStatus.normal;

  WSMessage({
    required this.text,
    required this.sender,
    required this.receiver,
    required this.type,
  }) : sendTime = DateTime.now();

  WSMessage.file({
    required this.filepath,
    required this.sender,
    required this.receiver,
    required this.type,
    required this.extend,
  })  : text = "",
        status = MessageStatus.upload,
        sendTime = DateTime.now();

  //
  MessageType _getType(int type) {
    return MessageType.values[type];
  }

  MessageStatus _getStatus(int type) {
    return MessageStatus.values[type];
  }

  //
  DateTime _toDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // database
  WSMessage.formLocal(dynamic json) {
    id = json['id'];
    text = json['text'];
    sender = json['sender'];
    receiver = json['receiver'];
    filepath = json['filepath'];
    type = _getType(json['type']);
    status = _getStatus(json['status']);
    sendTime = _toDateTime(json['timestamp']);
    if (json["extend"] != null) {
      extend = jsonDecode(json["extend"]);
    }
  }

  // server
  WSMessage.formServer(dynamic json) {
    text = json['text'];
    sender = json['sender'];
    receiver = json['receiver'];
    type = _getType(json['type']);
    sendTime = _toDateTime(json['send_time']);
    timestamp = json['timestamp'];
    if (json["extend"] != null) {
      if (json["extend"] is String && (json["extend"] as String).isNotEmpty) {
        extend = jsonDecode(json["extend"]);
      } else if (json["extend"] is Map) {
        extend = json["extend"];
      }
    }
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data["text"] = text;
    data["sender"] = sender;
    data["receiver"] = receiver;
    data["type"] = type.value;
    data["status"] = status.value;
    data["sendTime"] = sendTime.millisecondsSinceEpoch;
    if (extend != null) {
      data["extend"] = extend;
    }
    if (filepath != null) {
      data["filepath"] = filepath;
    }
    return data;
  }

  Map<String, dynamic> toSaveMap() {
    var data = <String, dynamic>{};
    data["text"] = text;
    data["sender"] = sender;
    data["receiver"] = receiver;
    data["type"] = type.value;
    data["timestamp"] = sendTime.millisecondsSinceEpoch;
    data["filepath"] = filepath;
    data["status"] = status.value;
    if (extend != null) {
      data["extend"] = jsonEncode(extend);
    }
    return data;
  }

  @override
  bool operator ==(Object other) {
    return other is WSMessage && id == other.id;
  }

  @override
  int get hashCode => id;
}
