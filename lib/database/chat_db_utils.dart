import 'dart:io';

import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/initialization.dart';
import 'package:path/path.dart' as path;

class ChatDatabase {
  static late Database _database;

  static const String _tableName = "chats";

  static Future open(String dirPath) async {
    String filepath = path.join(dirPath, "database.db");
    _database = await openDatabase(
      filepath,
      version: 1,
      onCreate: (Database db, int version) async {
        await _createChatTable(db);
      },
    );
  }

  // create table
  static Future<void> _createChatTable(Database db) {
    return db.execute(
      "CREATE TABLE chats("
      "id        INTEGER PRIMARY KEY,"
      "text      TEXT,"
      "receiver  VARCHAR(36),"
      "sender    VARCHAR(36),"
      "type      INT,"
      "timestamp INTEGER,"
      "filepath  VARCHAR(255),"
      "extend    VARCHAR(255),"
      "status    INT)",
    );
  }

  // update record
  static Future<int> update({
    required String where,
    required List<Object?>? whereArgs,
    required Map<String, Object?> values,
  }) {
    return _database.update(_tableName, values,
        where: where, whereArgs: whereArgs);
  }

  // insert record
  static Future<int> insertRecord(WSMessage message) {
    return _database.insert(_tableName, message.toSaveMap());
  }

  static void _deleteFile(String? filepath, MessageType type) async {
    if (filepath != null) {
      switch (type) {
        case MessageType.voice:
        case MessageType.video:
        case MessageType.picture:
          File deleteFile = File(filepath);
          if (await deleteFile.exists()) await deleteFile.delete();
          break;
        default:
      }
    }
  }

  static Future<int> deleteRow(WSMessage message) async {
    int count = await _database
        .delete(_tableName, where: "id = ?", whereArgs: [message.id]);
    _deleteFile(message.filepath, message.type);
    return count;
  }

  // delete record
  static Future<List<Object?>> deleteRecord(String receiver) async {
    // query data
    var records = await _database.query(
      _tableName,
      columns: ["id", "filepath", "type"],
      where: "receiver = ? OR sender = ?",
      whereArgs: [receiver, receiver],
    );
    var idList = <int>[];
    // delete cache file
    for (var element in records) {
      idList.add(element["id"] as int);
      final messageType = MessageType.values[element['type'] as int];
      _deleteFile(element["filepath"] as String?, messageType);
    }
    // delete records
    var batch = _database.batch();
    for (var element in idList) {
      batch.delete(_tableName, where: "id = ?", whereArgs: [element]);
    }
    var result = batch.commit();
    return result;
  }

  // query records
  static Future<List<WSMessage>> queryRecords({
    required String sender,
    required String receiver,
    int endId = 0,
    int limit = 15,
    String orderBy = "id desc",
  }) async {
    var whereCond =
        "((receiver = ? AND sender = ?) OR (sender = ? AND receiver = ?))";
    var whereArgs = <Object>[receiver, sender, receiver, sender];

    if (endId > 0) {
      whereCond += " AND id < ?";
      whereArgs.add(endId);
    }

    var records = await _database.query(_tableName,
        where: whereCond, whereArgs: whereArgs, orderBy: orderBy, limit: limit);

    var result = List.generate(
      records.length,
      (index) {
        return WSMessage.formLocal(records[index]);
      },
    );
    return result;
  }
}
