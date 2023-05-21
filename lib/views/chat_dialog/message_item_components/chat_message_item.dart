import 'dart:io';
import 'dart:math';

import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/providers/multiple_select_notifier.dart';
import 'package:flutter_chat_app/utils/database.dart';
import 'package:flutter_chat_app/utils/dio_instance.dart';
import 'package:flutter_chat_app/utils/iconfont.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/network_image.dart';
import 'package:flutter_chat_app/utils/route.dart';
import 'package:flutter_chat_app/views/chat_dialog/actions_bottom_sheet.dart';
import 'package:flutter_chat_app/views/chat_dialog/message_item_components/shap_component.dart';
import 'package:flutter_chat_app/views/chat_dialog/theme.dart';
import 'package:flutter_chat_app/views/client_list/avatar_component.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'text_component.dart';
import 'picture_component.dart';
import 'voice_component.dart';

class ChatMessageItem extends StatefulWidget {
  const ChatMessageItem({
    super.key,
    required this.isSelf,
    required this.message,
  });

  final bool isSelf;
  final WSMessage message;

  @override
  State<StatefulWidget> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem>
    with AutomaticKeepAliveClientMixin {
  final CancelToken _cancelToken = CancelToken();
  MessageStatus _status = MessageStatus.normal;
  CrossFadeState _avatarState = CrossFadeState.showFirst;

  @override
  void initState() {
    super.initState();
    _status = widget.message.status;
    if (_status == MessageStatus.upload) {
      _handleUploadFile();
    } else if (_status == MessageStatus.download) {
      if (widget.message.type == MessageType.voice) {
        _handleDownloadFile();
      }
    }
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  Widget _getMessageUI() {
    switch (widget.message.type) {
      case MessageType.text:
        return ShapeWrapComponent(
          onTap: () {},
          onLongPress: _handleItemLongPress,
          theme: widget.isSelf ? ChatTheme.right : ChatTheme.left,
          child: TextMessageComponent(
            theme: widget.isSelf ? ChatTheme.right : ChatTheme.left,
            message: widget.message,
          ),
        );
      case MessageType.voice:
        return VoiceMessageComponent(
          isSelf: widget.isSelf,
          message: widget.message,
          theme: widget.isSelf ? ChatTheme.right : ChatTheme.left,
          onLongPress: _handleItemLongPress,
          onPress: () {
            if (widget.message.status == MessageStatus.unread) {
              _changeStatus(MessageStatus.normal);
            }
          },
        );
      case MessageType.picture:
        return PictureMessageComponent(
          status: _status,
          message: widget.message,
          onLongPress: _handleItemLongPress,
        );
      default:
        return Container();
    }
  }

  // download file
  void _handleDownloadFile() {
    handleDownloadFile(
      widget.message.text,
      widget.message.filepath!,
      cancelToken: _cancelToken,
    ).then((value) {
      if (widget.message.type == MessageType.voice) {
        _changeStatus(MessageStatus.unread);
      } else {
        _changeStatus(MessageStatus.normal);
      }
    }).catchError((err) {});
  }

  // upload file
  void _handleUploadFile() {
    handleUploadFile(
      widget.message.sender,
      [widget.message.receiver],
      widget.message.filepath!,
      widget.message.type.value,
      extend: widget.message.extend,
      cancelToken: _cancelToken,
    ).then((value) {
      logger.i('data => ${value.data}');
      if (value.code == 200 &&
          value.success &&
          value.data.containsKey(widget.message.receiver) &&
          value.data[widget.message.receiver] == null) {
        _changeStatus(MessageStatus.normal);
      } else {
        _changeStatus(MessageStatus.error);
      }
    }).catchError((err) {
      logger.e(err);
      _changeStatus(MessageStatus.error);
    });
  }

  void _changeStatus(MessageStatus status) {
    //
    if (!_cancelToken.isCancelled) {
      widget.message.status = status;
      setState(() => _status = status);
    }
    // update database status
    ChatRecordDbUtil.update(
      where: "id = ?",
      whereArgs: [widget.message.id],
      values: {"status": status.value},
    );
  }

  void _deleteRecords() async {
    context.read<ChatProvider>().deleteRecords([widget.message]);
  }

  void _handleToMultipleChoiceState() {
    MultipleSelectNotifier.instance.enter();
    MultipleSelectNotifier.instance.add(
      widget.message,
      listener: _onMultipleChoiceStateChanged,
    );
  }

  void _onMultipleChoiceStateChanged(bool state) {
    if (!state) setState(() => _avatarState = CrossFadeState.showFirst);
  }

  void _handleSharedMessage() {
    Navigator.pushNamed(
      context,
      RouteName.shareUsersPage,
      arguments: widget.message,
    ).then((value) {
      if (value != null && value as bool) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            content: const Text('Send success'),
            action: SnackBarAction(
              label: "Close",
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
              },
            ),
          ),
        );
      }
    });
  }

  void _handleItemLongPress() async {
    if (MultipleSelectNotifier.instance.value) {
      if (_avatarState == CrossFadeState.showFirst) {
        setState(() => _avatarState = CrossFadeState.showSecond);
        MultipleSelectNotifier.instance.add(
          widget.message,
          listener: _onMultipleChoiceStateChanged,
        );
      } else {
        setState(() => _avatarState = CrossFadeState.showFirst);
        MultipleSelectNotifier.instance.remove(widget.message);
      }
      return;
    }
    setState(() => _avatarState = CrossFadeState.showSecond);

    var actions = [
      ActionType.shared,
      ActionType.multiple,
      ActionType.copy,
      ActionType.delete,
    ];
    //
    if (widget.message.status == MessageStatus.error) {
      actions.add(ActionType.send);
    }

    var tapActionType = await showModalBottomSheet(
      context: context,
      builder: (context) => ActionsBottomSheet(actions: actions),
    );

    if (!mounted) return;

    if (tapActionType != null && tapActionType is ActionType) {
      switch (tapActionType) {
        case ActionType.delete:
          _deleteRecords();
          break;
        case ActionType.shared:
          _handleSharedMessage();
          break;
        case ActionType.multiple:
          _handleToMultipleChoiceState();
          break;
        case ActionType.send:
          setState(() => _status = MessageStatus.upload);
          _handleUploadFile();
          break;
        case ActionType.copy:
          Clipboard.setData(ClipboardData(text: widget.message.text));
          break;
      }
    }

    if (!MultipleSelectNotifier.instance.value) {
      setState(() => _avatarState = CrossFadeState.showFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: widget.isSelf ? 36 : 0,
        right: widget.isSelf ? 0 : 36,
      ),
      constraints: const BoxConstraints(minHeight: 36.0),
      child: Row(
        mainAxisAlignment:
            widget.isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return _needReversed(widget.isSelf, [
      _getAvatar(),
      const SizedBox(width: 12),
      _getMessageUI(),
      _getStatusUI(),
    ]);
  }

  List<Widget> _needReversed(bool need, List<Widget> value) {
    return need ? value.reversed.toList() : value;
  }

  Widget _getAvatar() {
    late WSClient client;
    if (widget.isSelf) {
      client = Initialization.client!;
    } else {
      client = context.read<ChatProvider>().wsClient;
    }
    return AvatarComponent(
      width: 30,
      height: 30,
      client: client,
      selected: _avatarState == CrossFadeState.showSecond,
      showBadge: false,
    );
  }

  Widget _getStatusUI() {
    switch (_status) {
      case MessageStatus.upload:
        return _statusWrap(
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          ),
        );
      case MessageStatus.download:
        return Container();
      case MessageStatus.error:
        return _statusWrap(
          const Icon(
            Icons.info_outline,
            color: Color(0xFFF56C6C),
            size: 18.0,
          ),
        );
      case MessageStatus.unread:
        return _statusWrap(
          Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF56C6C),
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _statusWrap(Widget child) {
    return Container(
      width: 30,
      height: 36,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
