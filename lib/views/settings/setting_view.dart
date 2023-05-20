import 'package:desktop_app/utils/route.dart';
import 'package:flutter/material.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<StatefulWidget> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Setting"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("Manage client info"),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pushNamed(context, RouteName.initSettingPage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_copy_outlined),
            title: const Text("Manage local cache"),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pushNamed(context, RouteName.manageLocalCachePage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Manage permission"),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.pushNamed(context, RouteName.initPermissionPage);
            },
          ),
        ],
      ),
    );
  }
}
