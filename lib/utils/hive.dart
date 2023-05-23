//
import 'package:hive/hive.dart';

import '../models/ws_client_model.dart';

class HiveUtils {
  factory HiveUtils() {
    _instance ??= HiveUtils._();
    return _instance!;
  }

  HiveUtils._();

  static HiveUtils? _instance;

  static HiveUtils get instance => HiveUtils();

  late LazyBox<WSClient> clients;

  init(String filepath) async {
    Hive.init(filepath);
    Hive.registerAdapter(ClientCacheAdapter());
    clients = await Hive.openLazyBox("client.hive");
  }
}

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
