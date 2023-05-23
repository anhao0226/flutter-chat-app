import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

// abstract class DBTableInter<T> {
//   late String tableName;
//
//   late Database database;
//
//   List<T> query({
//     bool? distinct,
//     List<String>? columns,
//     String? where,
//     List<Object?>? whereArgs,
//     String? groupBy,
//     String? having,
//     String? orderBy,
//     int? limit,
//     int? offset,
//     Map<String, dynamic>? cond,
//   });
//
//   void delete();
// }
//
// class ChatTable implements DBTableInter<WSMessage> {
//   @override
//   String tableName = "chat";
//
//   @override
//   late Database database;
//
//   @override
//   void delete() {
//     // TODO: implement delete
//   }
//
//   @override
//   List<WSMessage> query({
//     bool? distinct,
//     List<String>? columns,
//     String? where,
//     List<Object?>? whereArgs,
//     String? groupBy,
//     String? having,
//     String? orderBy,
//     int? limit,
//     int? offset,
//     Map<String, dynamic>? cond,
//   }) {
//
//
//
//
//     database.query(tableName, where: where, whereArgs: whereArgs);
//     return [];
//   }
// }
//
// class DatabaseUtils {
//   factory DatabaseUtils() {
//     _instance ??= DatabaseUtils();
//     return _instance!;
//   }
//
//   static DatabaseUtils? _instance;
//
//   static DatabaseUtils get instance => DatabaseUtils();
//
//   static late Database _database;
//
//   static Database get database => _database;
//
//   final _tables = <String, DBTableInter>{};
//
//   DBTableInter table(String name) => _tables[name]!;
//
//   void register(DBTableInter table) {
//     table.database = _database;
//     _tables[table.tableName] = table;
//   }
//
//   Future<void> init(String dirPath) async {
//     String filepath = path.join(dirPath, "database.db");
//     _database = await openDatabase(
//       filepath,
//       version: 1,
//       onCreate: (Database db, int version) async {
//         await _createChatTable(db);
//       },
//     );
//
//     DatabaseUtils.instance.table("chat").query();
//   }
//
// }
//
// Future<void> _createChatTable(Database db) {
//   return db.execute(
//     "CREATE TABLE Chats("
//     "id        INTEGER PRIMARY KEY,"
//     "text      TEXT,"
//     "receiver  VARCHAR(36),"
//     "sender    VARCHAR(36),"
//     "type      INT,"
//     "timestamp INTEGER,"
//     "filepath  VARCHAR(255),"
//     "extend    VARCHAR(255),"
//     "status    INT)",
//   );
// }

// if (Platform.isLinux) {
// sqfliteFfiInit();
// _database = await databaseFactoryFfi.openDatabase(
// inMemoryDatabasePath,
// options: OpenDatabaseOptions(
// version: 1,
// onCreate: (Database db, int version) async {
// await db.execute(
// "CREATE TABLE Chats("
// "id        INTEGER PRIMARY KEY,"
// "text      TEXT,"
// "receiver  VARCHAR(36),"
// "sender    VARCHAR(36),"
// "type      INT,"
// "timestamp INTEGER,"
// "filepath  VARCHAR(255),"
// "extend    VARCHAR(255),"
// "status    INT)",
// );
// }),
// );
// } else {
// // sqlite
// String filepath02 = path.join(databasesPath, "chat.db");
// _database = await openDatabase(filepath02, version: 1,
// onCreate: (Database db, int version) async {
// await db.execute(
// "CREATE TABLE Chats("
// "id        INTEGER PRIMARY KEY,"
// "text      TEXT,"
// "receiver  VARCHAR(36),"
// "sender    VARCHAR(36),"
// "type      INT,"
// "timestamp INTEGER,"
// "filepath  VARCHAR(255),"
// "extend    VARCHAR(255),"
// "status    INT)",
// );
// });
// }

// if (Platform.isLinux || Platform.isWindows) {
// databaseFactory = databaseFactoryFfi;
// }
