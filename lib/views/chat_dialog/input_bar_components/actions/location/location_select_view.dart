import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/client_list/amap.dart';
import 'package:go_router/go_router.dart';

class SelectLocationView extends StatefulWidget {
  const SelectLocationView({super.key, required this.initLatLng});

  final LatLng initLatLng;

  @override
  State<StatefulWidget> createState() => _SelectLocationViewState();
}

class _SelectLocationViewState extends State<SelectLocationView> {
  Map<String, Object>? _result;

  @override
  Widget build(BuildContext context) {

    logger.i(widget.initLatLng);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(_result),
            child: const Text("Send"),
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AMapView(
              latLng: widget.initLatLng,
              onChanged: (Map<String, Object> value) {
                _result = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
