import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/providers/ws_client_management.dart';
import 'package:flutter_chat_app/utils/iconfont.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:go_router/go_router.dart';

import 'avatar_component.dart';

class ClientDetailsView extends StatelessWidget {
  const ClientDetailsView({super.key, required this.client});

  final WSClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              color: Colors.white,
              child: Column(
                children: [
                  Center(
                    child: AvatarComponent(
                      width: 80,
                      height: 80,
                      client: client,
                      online: client.online,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        client.nickname,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              color: Colors.white,
              child: TextButton(
                onPressed: () {
                  context.pushReplacement(
                    RoutePaths.clientChatting,
                    extra: client,
                  );
                },
                child: const Text("Send message"),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              color: Colors.white,
              child: TextButton(
                onPressed: () {
                  WSClientManagement.instance.removeItem(client);
                  context.pop();
                },
                child: const Text("Delete client"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
