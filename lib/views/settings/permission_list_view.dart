import 'package:desktop_app/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common_components/wrapper.dart';

class PermissionListView extends StatefulWidget {
  const PermissionListView({super.key});

  @override
  State<StatefulWidget> createState() => _PermissionListView();
}

class _Details {
  _Details(this.title, this.describe, this.permission, this.iconData);

  final String title;
  final String describe;
  final Permission permission;
  final IconData iconData;
  bool isGranted = false;
}

class _PermissionListView extends State<PermissionListView> {
  bool _isLoading = false;

  final _permissions = <_Details>[
    _Details(
      "Camera",
      "Required to be able to access the camera device.",
      Permission.camera,
      Icons.camera_alt,
    ),
    _Details(
      "Microphone",
      "Required to be able to access the microphone device.",
      Permission.microphone,
      Icons.mic_rounded,
    ),
    _Details(
      "Notification",
      "Allows an app to post notifications.",
      Permission.notification,
      Icons.notifications,
    ),
  ];

  @override
  void initState() {
    _handleInitPermissions();
    super.initState();
  }

  void _handleInitPermissions() async {
    _isLoading = true;
    for (var element in _permissions) {
      var status = await element.permission.status;
      if (status.isGranted) {
        setState(() => element.isGranted = true);
      }
    }
    setState(() => _isLoading = false);
  }

  void _handleRequestPermissions(bool value, int index) async {
    if (!value) return;

    // if (_permissions[index].title == "Notification") {
    //   openAppSettings();
    //   return;
    // }

    var status = await _permissions[index].permission.request();
    if (status.isGranted) {
      setState(() => _permissions[index].isGranted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Permissions"),
      ),
      body: Wrapper(
        isLoading: _isLoading,
        child: Column(
          children: List.generate(
            _permissions.length,
            (index) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: Container(
                width: 42,
                alignment: Alignment.center,
                child: Icon(_permissions[index].iconData),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_permissions[index].title),
                  Switch(
                    value: _permissions[index].isGranted,
                    onChanged: (value) =>
                        _handleRequestPermissions(value, index),
                  )
                ],
              ),
              subtitle: Text(_permissions[index].describe),
            ),
          ),
        ),
      ),
    );
  }
}
