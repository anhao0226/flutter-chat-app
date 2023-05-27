import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/views/chat_dialog/message_item_components/shap_component.dart';
import 'package:flutter_chat_app/views/client_list/amap.dart';
import 'package:go_router/go_router.dart';

class AmapMessageCard extends StatelessWidget {
  const AmapMessageCard({super.key, required this.latLng});

  final LatLng latLng;

  @override
  Widget build(BuildContext context) {
    const AMapPrivacyStatement amapPrivacyStatement =
        AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);

    final AMapWidget mapWidget = AMapWidget(
      initialCameraPosition: CameraPosition(target: latLng, zoom: 16),
      privacyStatement: amapPrivacyStatement,
      apiKey: const AMapApiKey(
        iosKey: AMapView.iosKey,
        androidKey: AMapView.androidKey,
      ),
      markers: <Marker>{Marker(position: latLng)},
      onMapCreated: (AMapController controller) {},
      onTap: (value) => context.push(RoutePaths.selectLocation),
    );

    return SizedBox(
      height: 100,
      child: mapWidget,
    );
  }
}
