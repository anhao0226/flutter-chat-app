import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/network_image.dart';

class AmapMessageCard extends StatelessWidget {
  const AmapMessageCard({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.message,
  });

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  final WSMessage message;

  @override
  Widget build(BuildContext context) {
    logger.i(message.toSaveMap());
    var address = message.extend!['address'];
    var filepath = message.extend!['snapshot'];

    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: Colors.white,
                child: Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 100,
                child: Image(
                  fit: BoxFit.fitWidth,
                  image: CustomNetworkImage(
                    message.text,
                    File(filepath),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
