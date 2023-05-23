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
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AvatarComponent(
                width: 80,
                height: 80,
                client: client,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(client.nickname),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: OutlinedButton(
                onPressed: () {
                  context.pushReplacement(
                    RoutePaths.clientChatting,
                    extra: client,
                  );
                },
                style: OutlinedButton.styleFrom(
                  elevation: 0,
                  // foregroundColor: Colors.white,
                  // backgroundColor: const Color(0xFF967ADC),
                ),
                child: const Text("Send message"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OutlinedButton(
                onPressed: () {
                  WSClientManagement.instance.removeItem(client);
                  context.pop();
                },
                style: OutlinedButton.styleFrom(
                  elevation: 0,
                  side: const BorderSide(
                    color: Colors.redAccent,
                  ),
                  foregroundColor: Colors.redAccent,
                  // backgroundColor: const Color(0xFF967ADC),
                ),
                child: const Text("Delete client"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
