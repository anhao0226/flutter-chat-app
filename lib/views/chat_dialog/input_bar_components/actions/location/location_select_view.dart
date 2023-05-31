import 'dart:async';
import 'dart:io';

import 'package:flutter_chat_app/api/amap_api.dart';
import 'package:path/path.dart' as path;
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/common_components/amap.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/models/amap/amap_poi.dart' as amap;

enum MapState { show, select }

class SelectLocationView extends StatefulWidget {
  const SelectLocationView({
    super.key,
    this.initLatLng,
    this.mapState = MapState.show,
  });

  final LatLng? initLatLng;
  final MapState mapState;

  @override
  State<StatefulWidget> createState() => _SelectLocationViewState();
}

class _SelectLocationViewState extends State<SelectLocationView> {
  final _result = <String, Object>{};
  final _actions = <Widget>[];
  Set<Marker> _markers = {};
  List<amap.AMapPoi> _pois = [];
  int _currSelectedIndex = 0;

  late AMapController _mapController;
  final AMapLocationController _aMapLocationController =
      AMapLocationController();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.mapState == MapState.show) {
      _markers.add(Marker(position: widget.initLatLng!));
    } else if (widget.mapState == MapState.select) {
      _actions.add(
        ElevatedButton(
          onPressed: _handleSendResult,
          child: const Text("Send"),
        ),
      );

      _subscription =
          _aMapLocationController.onLocationChanged.listen((result) {
        logger.i(result);
        var latLng = LatLng(
          (result["latitude"] ?? 39.909187) as double,
          (result["longitude"] ?? 116.397451) as double,
        );

        // copy value
        _result["latitude"] = latLng.latitude;
        _result["longitude"] = latLng.longitude;
        _result["address"] = result["address"] ?? "";
        _result["name"] = result["description"] ?? "";

        // 移动到当前定位点
        _mapController.moveCamera(CameraUpdate.newLatLng(latLng));
        // 获取周边定位点
        _handleSearchPlaceAround(latLng);
        setState(() => _markers.add(Marker(position: latLng)));
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) _subscription!.cancel();
  }

  //
  void _handleSearchPlaceAround(LatLng latLng) {
    fetchPlaceAround(latLng: latLng).then((value) {
      setState(() => _pois = value);
    }).catchError((err) {
      logger.i(err);
    });
  }

  void _handleSendResult() async {
    var bytes = await _mapController.takeSnapshot();
    var filename = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    var filepath = path.join(Initialization.temporaryDir.path, filename);
    var saveFile = File(filepath);
    if (!await saveFile.exists()) {
      await saveFile.create(recursive: true);
    }
    await saveFile.writeAsBytes(bytes as List<int>);
    if (!mounted) return;
    _result["snapshot"] = filepath;
    context.pop(_result);
  }

  void _handleSelectLocation(int index) {
    var locations = _pois[index].location.split(",");
    var latLng = LatLng(double.parse(locations[1]), double.parse(locations[0]));
    setState(() {
      _currSelectedIndex = index;
      _markers = <Marker>{Marker(position: latLng)};
    });
    // copy value
    _result["latitude"] = latLng.latitude;
    _result["longitude"] = latLng.longitude;
    _result["address"] = _pois[index].address;
    _result["name"] = _pois[index].name;
    _mapController.moveCamera(CameraUpdate.newLatLngZoom(latLng, 20));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: _actions,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AMapView(
              initialCameraPosition: CameraPosition(
                target: widget.initLatLng!,
                zoom: 18,
              ),
              markers: _markers,
              stack: [
                Positioned(
                  left: 10.0,
                  bottom: 30.0,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Icon(Icons.location_on),
                  ),
                )
              ],
              onCreated: (AMapController value) {
                _mapController = value;
                _aMapLocationController.startPosition();
              },
              // stack: _children,
            ),
          ),
          widget.mapState == MapState.select
              ? _getPlaceAroundLocationUI()
              : Container()
        ],
      ),
    );
  }

  Widget _getPlaceAroundLocationUI() {
    return Container(
      height: 300,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            height: 34.0,
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                width: 40,
                height: 4,
                color: Colors.black12,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _pois.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => _handleSelectLocation(index),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(_pois[index].name),
                    subtitle: Text('${_pois[index].distance}m'),
                    trailing: AnimatedCrossFade(
                      firstChild: const SizedBox(),
                      secondChild: const Icon(Icons.check),
                      crossFadeState: _currSelectedIndex == index
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          ),
        ],
      ),
    );
  }
}
