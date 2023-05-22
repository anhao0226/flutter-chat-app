import 'dart:convert';
import 'dart:io';

import 'package:flutter_chat_app/models/client_state.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/utils/database.dart';
import 'package:flutter_chat_app/utils/dio_instance.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Initialization {
  static String? _host;
  static String? _port;
  static WSClient? _client;
  static late Directory _voiceSaveDir;
  static late Directory _pictureSaveDir;
  static late Directory _avatarDir;
  static late Directory _temporaryDir;
  static late Directory _appDocumentsDir;
  static late SharedPreferences _prefs;
  static late Database _database;
  static late LazyBox<WSClient> _clientCacheHive;

  static String? get address => [_host, _port].join(":");

  static String? get port => _port;

  static String? get host => _host;

  static WSClient? get client => _client;

  static SharedPreferences get prefs => _prefs;

  static Directory get temporaryDir => _temporaryDir;

  static Directory get appDocumentsDir => _appDocumentsDir;

  static Directory get voiceSaveDir => _voiceSaveDir;

  static Directory get pictureSaveDir => _pictureSaveDir;

  static Directory get avatarDir => _avatarDir;

  static Database get database => _database;

  static LazyBox<WSClient> get clientsCache => _clientCacheHive;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();

    // _prefs.clear();
    //
    _initSeverSetting();
    //
    localClientCache();
    //
    _temporaryDir = await getTemporaryDirectory();
    _appDocumentsDir = await getApplicationDocumentsDirectory();
    _voiceSaveDir = Directory("${_appDocumentsDir.path}/voices");
    if (!await _voiceSaveDir.exists()) {
      _voiceSaveDir.create(recursive: true);
    }
    //
    _pictureSaveDir = Directory("${_appDocumentsDir.path}/pictures");
    if (!await _pictureSaveDir.exists()) {
      _pictureSaveDir.create(recursive: true);
    }
    //
    _avatarDir = Directory("${_appDocumentsDir.path}/avatars");
    if (!await _avatarDir.exists()) {
      _avatarDir.create(recursive: true);
    }

    if (Platform.isLinux || Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
    }

    // Init database
    var databasesPath = await getDatabasesPath();

    if (Platform.isLinux) {
      sqfliteFfiInit();
      _database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (Database db, int version) async {
              await db.execute(
                "CREATE TABLE Chats("
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
            }),
      );
    } else {

      // sqlite
      String filepath02 = path.join(databasesPath, "chat.db");
      _database = await openDatabase(filepath02, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE Chats("
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
      });
    }

    Hive.init(path.join(databasesPath, "client_cache"));
    Hive.registerAdapter(ClientCacheAdapter());
    _clientCacheHive = await Hive.openLazyBox("client.hive");

    // var sqlStr = "ALTER TABLE chats ADD COLUMN status int default 0";
    // _database.execute(sqlStr);
  }

  static Future<bool> clearCache(List<String> values) async {
    try {
      for (var element in values) {
        await _clientCacheHive.delete(element);
        await ChatRecordDbUtil.deleteRecord(element);
      }
      return true;
    } catch (err) {
      logger.e(err);
      return Future.error(err);
    }
  }

  static void writeClientCache(WSClient client) {
    _client = client;
    var jsonStr = jsonEncode(client.toJson());
    _prefs.setString("_CLIENT", jsonStr);
  }

  static void localClientCache() {
    var clientCache = _prefs.getString("_CLIENT");
    if (clientCache != null) {
      Map<String, dynamic> toJson = jsonDecode(clientCache);
      _client = WSClient.formCache(toJson);
    }
  }

  static void writeHost(String host) {
    _prefs.setString("_HOST", _host = host);
  }

  static void writePort(String port) {
    _prefs.setString("_POST", _port = port);
  }

  static void _initSeverSetting() {
    _host = _prefs.getString("_HOST");
    _port = _prefs.getString("_POST");
  }

  static Uri? websocketConnUrl() {
    if (_client == null) return null;
    return Uri(
      path: "/ws",
      scheme: "ws",
      host: _host,
      port: int.parse(_port!),
      queryParameters: {
        "uid": _client!.uid,
        "nickname": _client!.nickname,
        "avatarUrl": _client!.avatarUrl,
      },
    );
  }

  static bool isValidConfig() {
    return _host != null && _port != null && _client != null;
  }
}

//
class ClientCacheAdapter extends TypeAdapter<WSClient> {
  @override
  final typeId = 0;

  @override
  WSClient read(BinaryReader reader) {
    return WSClient.formCache(reader.read());
  }

  @override
  void write(BinaryWriter writer, WSClient obj) {
    writer.write(obj.toJson());
  }
}
