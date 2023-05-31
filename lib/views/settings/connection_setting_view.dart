import 'package:flutter_chat_app/color_schemes.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
import 'package:go_router/go_router.dart';

import '../client_list/avatar_component.dart';

typedef NextCallback = void Function(String nickname, String host, int port);

class ConnectionSettingsView extends StatefulWidget {
  const ConnectionSettingsView({
    super.key,
    this.onNext,
    this.initStep = false,
  });

  final NextCallback? onNext;

  final bool initStep;

  @override
  State<StatefulWidget> createState() => _ConnectionSettingsViewState();
}

class _ConnectionSettingsViewState extends State<ConnectionSettingsView> {
  final TextEditingController _hostEditingController = TextEditingController();
  final TextEditingController _nicknameEditingController =
      TextEditingController();
  final TextEditingController _portEditingController = TextEditingController();

  WSClient? _wsClient;

  @override
  void initState() {
    super.initState();
    if (Initialization.host != null) {
      _hostEditingController.value =
          TextEditingValue(text: Initialization.host!);
    }
    if (Initialization.port != null) {
      _portEditingController.value =
          TextEditingValue(text: Initialization.port!.toString());
    }

    if (Initialization.client != null) {
      _wsClient = Initialization.client;
      _nicknameEditingController.value =
          TextEditingValue(text: Initialization.client!.nickname);
    }
  }

  void _handleNext() async {
    if (_nicknameEditingController.text.isNotEmpty &&
        _hostEditingController.text.isNotEmpty &&
        _portEditingController.text.isNotEmpty) {
      widget.onNext!(
        _nicknameEditingController.text,
        _hostEditingController.text,
        int.tryParse(_portEditingController.text) ?? 8080,
      );
    }
  }

  void _handleWsConnection() {
    var host = _hostEditingController.text;
    var port = int.tryParse(_portEditingController.text) ?? 8080;
    WSUtil.instance
        .initWebSocket(
      host: host,
      port: port,
      client: Initialization.client!,
    )
        .then((value) {
      // update cache
      Initialization.writeServerConfig(host, port);
      context.pop();
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          widget.initStep
              ? TextButton(
                  onPressed: _handleNext,
                  child: const Text("Next"),
                )
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.only(left: 18, right: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _getAvatarUI(),
                _buildInputBox(
                  label: "Nickname",
                  hintText: Initialization.client != null
                      ? Initialization.client!.nickname
                      : "",
                  controller: _nicknameEditingController,
                ),
                _buildInputBox(
                  label: "Host",
                  hintText: Initialization.host,
                  controller: _hostEditingController,
                ),
                _buildInputBox(
                  label: "Port",
                  hintText: Initialization.port.toString(),
                  controller: _portEditingController,
                ),
                const SizedBox(height: 30.0),
                widget.initStep
                    ? Container()
                    : ElevatedButton(
                        onPressed: _handleWsConnection,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: lightColorScheme.primary,
                          foregroundColor: lightColorScheme.onPrimary,
                        ),
                        child: const Text("Connect"),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getAvatarUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: _wsClient != null
            ? AvatarComponent(
                width: 80.0,
                height: 80.0,
                client: _wsClient!,
                selected: false,
                showBadge: false,
              )
            : Container(
                height: 140,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset("assets/icons/chat.png"),
              ),
      ),
    );
  }

  Widget _buildInputBox({
    required String label,
    required TextEditingController controller,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 14, top: 24),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: const Color(0xFFF5F7FA),
            height: 44,
            child: Center(
              child: TextField(
                maxLines: 1,
                cursorColor: Colors.black,
                controller: controller,
                keyboardType: TextInputType.multiline,
                onChanged: (text) {},
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  hintText: hintText,
                  fillColor: const Color(0xFFF5F7FA),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
