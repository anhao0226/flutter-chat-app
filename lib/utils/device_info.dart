import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

final deviceInfoPlugin = DeviceInfoPlugin();

// Linux
Map<String, dynamic> readLinuxDeviceInfo(LinuxDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'version': data.version,
    'id': data.id,
    'idLike': data.idLike,
    'versionCodename': data.versionCodename,
    'versionId': data.versionId,
    'prettyName': data.prettyName,
    'buildId': data.buildId,
    'variant': data.variant,
    'variantId': data.variantId,
    'machineId': data.machineId,
  };
}

// Android
Future<Map<String, dynamic>> readAndroidBuildData() async {
  var build = await deviceInfoPlugin.androidInfo;
  return <String, dynamic>{
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    // 'systemFeatures': build.systemFeatures,
  };
}

Future<Map<String, dynamic>> getNetworkInfo() async {
  final info = NetworkInfo();
  var data = <String, dynamic>{};
  data["wifiName"] = await info.getWifiName();
  data["wifiBSSID"] = await info.getWifiBSSID();
  data["wifiIP"] = await info.getWifiIP();
  data["wifiIPv6"] = await info.getWifiIPv6();
  data["wifiSubmask"] = await info.getWifiSubmask();
  data["wifiBroadcast"] = await info.getWifiBroadcast();
  data["wifiGateway"] = await info.getWifiGatewayIP();
  return data;
}
