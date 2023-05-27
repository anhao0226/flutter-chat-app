import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/providers/ws_client_management.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/chat_dialog/input_bar_components/chat_input_bar_component.dart';
import 'package:flutter_chat_app/views/chat_dialog/status_bar_component.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_dialog_appbar.dart';
import 'message_item_components/chat_message_item.dart';

class ChatDialogView extends StatefulWidget {
  const ChatDialogView({Key? key, required this.client}) : super(key: key);

  final WSClient client;

  @override
  State<StatefulWidget> createState() => _ChatDialogViewState();
}

class _ChatDialogViewState extends State<ChatDialogView>
    with WidgetsBindingObserver {
  final centerKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final InputBarController _inputBarController = InputBarController();
  double _bottomPadding = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ChatProvider>().onNewMessage(() {
      _scrollToBottom();
    });
    // add scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        context.read<ChatProvider>().handleMoreData();
      }
    });
    //
    _bottomPadding = _inputBarController.height;
    _scrollToBottom();
    _inputBarController.addListener(() {
      setState(() => _bottomPadding = _inputBarController.height);
      _scrollToBottom();
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          _inputBarController.close();
          _scrollToBottom();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _inputBarController.dispose();
    WSClientManagement.instance.exitChatStatus();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _handleSendMessage(
    String text,
    MessageType type,
    Map<String, dynamic>? extend,
  ) {

    logger.i(extend);

    if (type == MessageType.picture) Navigator.pop(context);
    context
        .read<ChatProvider>()
        .sendMessage(text: text, type: type, extend: extend);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void _handleResetState() {
    FocusScope.of(context).unfocus();
    _inputBarController.close();
  }

  @override
  Widget build(BuildContext context) {
    var isLoading = context.select(
      (ChatProvider value) => value.isLoading,
    );
    var showStatusBar = context.select(
      (ChatProvider value) => value.showStatusBar,
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: ChatDialogAppbar(client: widget.client),
      body: InkWell(
        onTap: () => _handleResetState(),
        child: Wrapper(
          isLoading: isLoading,
          stack: [
            StatusBarComponent(
              isOpen: showStatusBar,
            ),
            InputBarComponent(
              controller: _inputBarController,
              onSend: _handleSendMessage,
            ),
          ],
          child: CustomScrollView(
            center: centerKey,
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildLoadingUI()),
              Consumer<ChatProvider>(builder: (context, value, child) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItem(index, value.cacheMessage),
                      childCount: value.cacheMessage.length,
                    ),
                  ),
                );
              }),
              SliverPadding(
                padding: EdgeInsets.zero,
                key: centerKey,
              ),
              Consumer<ChatProvider>(builder: (context, value, child) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItem(index, value.messages),
                      childCount: value.messages.length,
                    ),
                  ),
                );
              }),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: _bottomPadding + 10,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    var component = Container();
    var loadingState = context.select(
      (ChatProvider value) => value.loadingState,
    );
    if (loadingState == LoadingState.idle) {
      component = Container(
        height: 50.0,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }
    return component;
  }

  Widget _buildItem(int index, List<WSMessage> messages) {
    var isSelf = messages[index].sender == Initialization.client!.uid;
    Widget component = Container();
    // 计算时间差
    if (index > 0) {
      var duration =
          messages[index - 1].sendTime.difference(messages[index].sendTime);
      if (duration.inSeconds > 5 * 60) {
        component = Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          alignment: Alignment.center,
          child: Text(
            dateFormat(messages[index - 1].sendTime),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA8ABB2),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        component,
        ChatMessageItem(
          key: ValueKey<int>(messages[index].id),
          isSelf: isSelf,
          message: messages[index],
        ),
      ],
    );
  }
}
