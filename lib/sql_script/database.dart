import 'dart:io';

import 'package:sqflite/sqflite.dart';

late Database _database;

void _initDatabase() async {
  var databasesPath = await getDatabasesPath();
  String path = <String>[databasesPath, "chat.db"].join("/");
  _database = await openDatabase(path);

  _handleUpdateTable();
}

void _handleReadSqlFiles(String dirPath) {
  Directory directory = Directory(dirPath);
  directory.listSync().forEach((element) async {
    final filepath = element.path;
    final fileSuffixIndex = filepath.lastIndexOf(".");
    if (filepath.substring(fileSuffixIndex + 1) == "sql") {
      var content = await File(element.path).readAsString();
      _handleCreateDatabase(content);
    }
  });
}

void _handleCreateDatabase(String sqlStr) async {}

Future<void> _handleUpdateTable() async {
  var sqlStr = "ALTER TABLE chats ADD COLUMN status int;";
  await _database.execute(sqlStr);
}

void main() {
  _initDatabase();
  _handleReadSqlFiles(".");
}
