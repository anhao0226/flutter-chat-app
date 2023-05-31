import 'dart:convert';
import 'dart:io';

import 'package:flutter_chat_app/database/chat_db_utils.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/utils/hive.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/database.dart';

class Initialization {
  static String? _host;
  static int? _port;
  static WSClient? _client;
  static late Directory _voiceSaveDir;
  static late Directory _pictureSaveDir;
  static late Directory _avatarDir;
  static late Directory _unknownFileDir;
  static late Directory _temporaryDir;
  static late Directory _appDocumentsDir;
  static late SharedPreferences _prefs;

  static String? get address => [_host, _port].join(":");

  static int? get port => _port;

  static String? get host => _host;

  static WSClient? get client => _client;

  static SharedPreferences get prefs => _prefs;

  //
  static Directory get temporaryDir => _temporaryDir;

  static Directory get appDocumentsDir => _appDocumentsDir;

  static Directory get voiceSaveDir => _voiceSaveDir;

  static Directory get pictureSaveDir => _pictureSaveDir;

  static Directory get avatarDir => _avatarDir;

  static Directory get unknownFileDir => _unknownFileDir;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    // _prefs.clear();
    //
    _initSeverSetting();
    //
    localClientCache();

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

    _unknownFileDir = Directory("${_appDocumentsDir.path}/others");
    if (!await _unknownFileDir.exists()) {
      _unknownFileDir.create(recursive: true);
    }

    // Init database
    var databasesPath = await getDatabasesPath();
    await HiveUtils.instance.init(path.join(databasesPath, "client_cache"));
    await ChatDatabase.open(databasesPath);
  }

  static Future<bool> clearCache(List<String> values) async {
    try {
      for (var element in values) {
        await HiveUtils.instance.clients.delete(element);
        await ChatDatabase.deleteRecord(element);
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

  static void writeServerConfig(String host, int port) {
    _prefs.setString("_HOST", _host = host);
    _prefs.setInt("_POST", _port = port);
  }

  static void _initSeverSetting() {
    _host = _prefs.getString("_HOST");
    _port = _prefs.getInt("_POST") ?? 8080;
  }

  static bool isValidConfig() {
    return _host != null && _port != null && _client != null;
  }
}
