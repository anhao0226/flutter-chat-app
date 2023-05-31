import 'dart:async';
import 'dart:io';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:amap_flutter_base/amap_flutter_base.dart';

const _iosKey = "5502205ef8232e80666b21d8d7f925e7";
const _androidKey = "5502205ef8232e80666b21d8d7f925e7";

class AMapView extends StatefulWidget {
  const AMapView({
    super.key,
    required this.onCreated,
    this.stack = const [],
    this.initialCameraPosition =
        const CameraPosition(target: LatLng(39.909187, 116.397451), zoom: 20),
    this.markers = const <Marker>{},
  });

  final List<Widget> stack;
  final Set<Marker> markers;
  final CameraPosition initialCameraPosition;
  final ValueChanged<AMapController> onCreated;

  static const String androidKey = _androidKey;

  static const String iosKey = _iosKey;

  @override
  State<StatefulWidget> createState() => _AMapViewState();
}

class _AMapViewState extends State<AMapView> {
  AMapController? _mapController;
  final _approvalNumberWidget = <Widget>[];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    if (widget.markers.isNotEmpty) {
      _markers.addAll(widget.markers);
    }

    /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    /// <b>必须保证在调用定位功能之前调用， 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    /// [hasContains] 隐私声明中是否包含高德隐私政策说明
    /// [hasShow] 隐私权政策是否弹窗展示告知用户
    AMapFlutterLocation.updatePrivacyShow(true, true);

    /// 设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作
    /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
    /// <b>必须保证在调用定位功能之前调用, 建议首次启动App时弹出《隐私政策》并取得用户同意</b>
    /// [hasAgree] 隐私权政策是否已经取得用户同意
    AMapFlutterLocation.updatePrivacyAgree(true);

    requestPermission();

    AMapFlutterLocation.setApiKey(_androidKey, _iosKey);
  }

  @override
  void didUpdateWidget(covariant AMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => _markers = widget.markers);
  }

  void _handleMapCreated(AMapController controller) {
    widget.onCreated(controller);
    _mapController = controller;
    getApprovalNumber();
  }

  @override
  Widget build(BuildContext context) {
    const AMapPrivacyStatement amapPrivacyStatement =
        AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);

    final AMapWidget mapWidget = AMapWidget(
      privacyStatement: amapPrivacyStatement,
      initialCameraPosition: widget.initialCameraPosition,
      apiKey: const AMapApiKey(androidKey: _androidKey, iosKey: _iosKey),
      markers: _markers,
      onMapCreated: _handleMapCreated,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            child: mapWidget,
          ),
          Positioned(
            right: 10,
            bottom: 15,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _approvalNumberWidget,
              ),
            ),
          ),
          ...widget.stack,
        ],
      ),
    );
  }

  void getApprovalNumber() async {
    //普通地图审图号
    String? mapContentApprovalNumber =
        await _mapController!.getMapContentApprovalNumber();
    //卫星地图审图号
    String? satelliteImageApprovalNumber =
        await _mapController!.getSatelliteImageApprovalNumber();

    setState(() {
      if (null != mapContentApprovalNumber) {
        _approvalNumberWidget.add(Text(mapContentApprovalNumber));
      }
      if (null != satelliteImageApprovalNumber) {
        _approvalNumberWidget.add(Text(satelliteImageApprovalNumber));
      }
    });
  }

  /// 动态申请定位权限
  void requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await _requestLocationPermission();
    if (hasLocationPermission) {
      logger.i("定位权限申请通过");
    } else {
      logger.i("定位权限申请不通过");
    }
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> _requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    logger.i(status);
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }
}

class AMapLocationController {
  final _locationPlugin = AMapFlutterLocation();

  Stream<Map<String, Object>> get onLocationChanged =>
      _locationPlugin.onLocationChanged();

  AMapLocationController() {
    _setLocationOption();
    if (Platform.isIOS) _requestAccuracyAuthorization();
  }

  startPosition() {
    _locationPlugin.startLocation();
  }

  stopPosition() {
    _locationPlugin.stopLocation();
  }

  void _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption();
    // 是否单次定位
    locationOption.onceLocation = true;
    // 是否需要返回逆地理信息
    locationOption.needAddress = true;
    // 逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.DEFAULT;

    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    // 设置Android端连续定位的定位间隔
    locationOption.locationInterval = 2000;

    // 设置Android端的定位模式<br>
    locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

    // 设置iOS端的定位最小更新距离<br>
    locationOption.distanceFilter = -1;

    // 设置iOS端期望的定位精度
    locationOption.desiredAccuracy = DesiredAccuracy.Best;

    // 设置iOS端是否允许系统暂停定位
    locationOption.pausesLocationUpdatesAutomatically = false;

    // 将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }

  ///获取iOS native的accuracyAuthorization类型
  void _requestAccuracyAuthorization() async {
    AMapAccuracyAuthorization currentAccuracyAuthorization =
        await _locationPlugin.getSystemAccuracyAuthorization();
    if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
      print("精确定位类型");
    } else if (currentAccuracyAuthorization ==
        AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
      print("模糊定位类型");
    } else {
      print("未知定位类型");
    }
  }
}
