import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
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
              child: ElevatedButton.icon(
                onPressed: () {
                  context.replace(RoutePaths.clientChatting, extra: client);
                },
                icon: const Text("Send message"),
                label: const Icon(Iconfonts.send),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF967ADC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
