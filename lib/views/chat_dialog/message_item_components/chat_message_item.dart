import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'package:flutter_chat_app/api/message.dart';
import 'package:flutter_chat_app/database/chat_db_utils.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/providers/multiple_select_notifier.dart';
import 'package:flutter_chat_app/utils/dio_instance.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/views/chat_dialog/actions_bottom_sheet.dart';
import 'package:flutter_chat_app/views/chat_dialog/message_item_components/file_component.dart';
import 'package:flutter_chat_app/views/chat_dialog/message_item_components/shap_component.dart';
import 'package:flutter_chat_app/views/chat_dialog/theme.dart';
import 'package:flutter_chat_app/views/client_list/avatar_component.dart';

import '../input_bar_components/actions/location/location_message_card.dart';
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
  MessageStatus _status = MessageStatus.normal;
  CrossFadeState _avatarState = CrossFadeState.showFirst;
  List<ActionType> _sharedActions = [];

  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    logger.i(_status);
    _status = widget.message.status;
    if (_status == MessageStatus.send) {
      logger.i(_status);
      _handleSendMessage();
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

  void _handleSendMessage() {
    logger.i(widget.message.toSaveMap());
    handleSendMessage(
      text: widget.message.text,
      sender: widget.message.sender,
      msgType: widget.message.type,
      extend: widget.message.extend,
      receivers: [widget.message.receiver],
      cancelToken: _cancelToken,
    ).then((value) {
      if (value.success &&
          value.data.containsKey(widget.message.receiver) &&
          value.data[widget.message.receiver] == null) {
        _changeStatus(MessageStatus.normal);
      } else {
        _changeStatus(MessageStatus.error);
      }
    }).catchError((err) {
      logger.i(err);
      _changeStatus(MessageStatus.error);
    });
  }

  Widget _getMessageUI() {
    _sharedActions = [
      ActionType.shared,
      ActionType.multiple,
      ActionType.delete,
    ];
    switch (widget.message.type) {
      case MessageType.text:
        _sharedActions.add(ActionType.copy);
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
      case MessageType.file:
        _sharedActions.add(ActionType.download);
        return FileMessageComponent(
          message: widget.message,
          theme: widget.isSelf ? ChatTheme.right : ChatTheme.left,
          onLongPress: _handleItemLongPress,
        );
      case MessageType.location:
        var extend = widget.message.extend!;
        var latLng = LatLng(extend["latitude"]!, extend["longitude"]!);
        return AmapMessageCard(
          message: widget.message,
          onTap: () => context.push(
            RoutePaths.selectLocation,
            extra: <String, dynamic>{"latLng": latLng},
          ),
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

  void _changeStatus(MessageStatus status) {
    widget.message.status = status;
    if (!_cancelToken.isCancelled) setState(() => _status = status);
    // 更新数据库状态
    ChatDatabase.update(
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
    context.push(RoutePaths.clientShared, extra: widget.message).then((value) {
      if (value != null && value as bool) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            showCloseIcon: true,
            duration: Duration(seconds: 3),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            content: Text('Send success'),
          ),
        );
      }
    });
  }

  void _handleSaveFileToLocal() async {
    var directory = await getApplicationDocumentsDirectory();
    logger.i(directory);
    if (await Permission.manageExternalStorage.status.isGranted) {
      var directory = await getExternalStorageDirectory();
      logger.i(directory);
    } else {
      await Permission.manageExternalStorage.request();
    }
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

    if (widget.message.status == MessageStatus.error) {
      _sharedActions.add(ActionType.send);
    }

    var tapActionType = await showModalBottomSheet(
      context: context,
      builder: (context) => ActionsBottomSheet(actions: _sharedActions),
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
          _handleSendMessage();
          break;
        case ActionType.copy:
          Clipboard.setData(ClipboardData(text: widget.message.text));
          break;
        case ActionType.download:
          _handleSaveFileToLocal();
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
        children: _needReversed(widget.isSelf, [
          _getAvatar(),
          const SizedBox(width: 12),
          _getMessageUI(),
          _getStatusUI(),
        ]),
      ),
    );
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
