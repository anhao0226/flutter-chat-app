import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Operation { clear }

class UserChatSettingView extends StatefulWidget {
  const UserChatSettingView({super.key, required this.client});

  final WSClient client;

  @override
  State<StatefulWidget> createState() => _UserChatSettingViewState();
}

class _UserChatSettingViewState extends State<UserChatSettingView> {
  List<Operation> actions = [];

  void _handleClearChatHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear Chat History"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // ChatRecordDbUtil.deleteRecord(widget.client.uid);
                // actions.add(Operation.clear);
                // Navigator.pop(context);
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, actions);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          foregroundColor: const Color(0xFF303133),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            ListTile(
              title: const Text("Clear Chat History"),
              trailing: const Icon(Icons.navigate_next),
              onTap: () => _handleClearChatHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
