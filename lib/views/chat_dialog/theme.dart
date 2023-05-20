import 'package:flutter/cupertino.dart';

class MessageTheme {
  late Color fontColor;
  late Color backgroundColor;
  late MainAxisAlignment mainAxisAlignment;
  late BorderRadius borderRadius;
  late Color processBarColor;

  MessageTheme({
    required this.fontColor,
    required this.backgroundColor,
    required this.mainAxisAlignment,
    required this.borderRadius,
    required this.processBarColor,
  });
}

class ChatTheme {
  static MessageTheme left = MessageTheme(
    fontColor: const Color(0xFFF5F7FA),
    backgroundColor: const Color(0xFFAC92EC),
    mainAxisAlignment: MainAxisAlignment.start,
    processBarColor: const Color.fromRGBO(255, 255, 255, 0.2),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    ),
  );

  static MessageTheme right = MessageTheme(
    fontColor: const Color(0xFF656D78),
    backgroundColor: const Color(0xFFFFFFFF),
    mainAxisAlignment: MainAxisAlignment.end,
    processBarColor: const Color.fromRGBO(188, 164, 227, 0.16),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(0),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    ),
  );
}
