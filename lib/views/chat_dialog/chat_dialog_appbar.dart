import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/providers/multiple_select_notifier.dart';
import 'package:flutter_chat_app/utils/route.dart';
import 'package:flutter_chat_app/views/chat_dialog/actions_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatDialogAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ChatDialogAppbar({
    super.key,
    required this.client,
  });

  final WSClient client;

  void _handleActions(BuildContext context) {
    Navigator.pushNamed(
      context,
      RouteName.userChatSettingPage,
      arguments: client,
    ).then((value) {});
  }

  void _handleMultipleDone(BuildContext context) async {
    var actionType = await showModalBottomSheet(
      context: context,
      builder: (_) => const ActionsBottomSheet(
        actions: [ActionType.delete],
      ),
    );

    if (context.mounted) {
      if (actionType != null && actionType is ActionType) {
        switch (actionType) {
          case ActionType.delete:
            _handleDelRecords(context);
            break;
          default:
        }
      }
    }
  }

  void _handleDelRecords(BuildContext context) {
    var items = MultipleSelectNotifier.instance.selectedItems;
    context.read<ChatProvider>().deleteRecords(items);
    MultipleSelectNotifier.instance.exits();
  }

  Future<bool> _handleSysBack(BuildContext context) async {
    if (MultipleSelectNotifier.instance.value) {
      MultipleSelectNotifier.instance.exits();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var state = CrossFadeState.showFirst;
    if (context.watch<MultipleSelectNotifier>().value) {
      state = CrossFadeState.showSecond;
    }
    return WillPopScope(
      onWillPop: () => _handleSysBack(context),
      child: AppBar(
        leading: Center(
          child: AnimatedCrossFade(
            alignment: Alignment.center,
            firstChild: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            secondChild: IconButton(
              onPressed: () {
                MultipleSelectNotifier.instance.exits();
              },
              icon: const Icon(Icons.close),
            ),
            crossFadeState: state,
            duration: const Duration(milliseconds: 400),
          ),
        ),
        centerTitle: true,
        title: Text(
          client.nickname,
          overflow: TextOverflow.ellipsis,
        ),
        titleSpacing: 0,
        actions: _getActionsUI(context, state),
      ),
    );
  }

  List<Widget> _getActionsUI(BuildContext context, CrossFadeState state) {
    var isOnline = context.select(
      (ChatProvider value) => value.isOnline,
    );
    var showStatusBar = context.select(
      (ChatProvider value) => value.showStatusBar,
    );
    return <Widget>[
      AnimatedCrossFade(
        alignment: Alignment.center,
        firstChild: Center(
          child: IconButton(
            onPressed: () => _handleActions(context),
            icon: const Icon(
              size: 18,
              Icons.link_off_outlined,
              color: Color(0xFFF56C6C),
            ),
          ),
        ),
        secondChild: Container(),
        crossFadeState: showStatusBar || isOnline
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
      AnimatedCrossFade(
        alignment: Alignment.center,
        firstChild: Center(
          child: IconButton(
            onPressed: () => _handleActions(context),
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ),
        secondChild: Center(
          child: IconButton(
            onPressed: () => _handleMultipleDone(context),
            icon: const Icon(Icons.check),
          ),
        ),
        crossFadeState: state,
        duration: const Duration(milliseconds: 300),
      ),
    ];
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
