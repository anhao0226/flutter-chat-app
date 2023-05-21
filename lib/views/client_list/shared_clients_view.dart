import 'dart:io';

import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/providers/ws_client_management.dart';
import 'package:flutter_chat_app/utils/database.dart';
import 'package:flutter_chat_app/utils/dio_instance.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
import 'package:flutter_chat_app/views/animations/fade_animation.dart';
import 'package:flutter_chat_app/views/client_list/avatar_component.dart';
import 'package:flutter_chat_app/views/client_list/shared_cleint_dialog.dart';
import 'package:flutter_chat_app/views/client_list/shared_err_bottom_sheet.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SharedClientListView extends StatefulWidget {
  const SharedClientListView({super.key, required this.message});

  final WSMessage message;

  @override
  State<StatefulWidget> createState() => _SharedClientListViewState();
}

class _SharedClientListViewState extends State<SharedClientListView> {
  CrossFadeState _crossFadeState = CrossFadeState.showFirst;
  final _clientsMap = <String, WSClient>{};
  final List<WSClient> _clients = [];
  bool _isLoading = false;
  bool _isSendingState = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    _isLoading = true;
    fetchClientList().then((value) {
      var records = value.data.skipWhile(
        (value) => value.uid == Initialization.client!.uid,
      );
      setState(() {
        _clients.addAll(records);
        _isLoading = false;
      });
    });
  }

  void _handleUploadFile() {
    var receivers = <String>[];
    _clientsMap.forEach((key, value) => receivers.add(key));
    setState(() {
      _isLoading = true;
      _isSendingState = true;
    });
    if (widget.message.type == MessageType.text) {
      for (var receiver in receivers) {
        WSUtil.instance.messageWrap(
            widget.message.text, receiver, widget.message.type, null);
      }
    } else {
      handleUploadFile(
        widget.message.sender,
        receivers,
        widget.message.filepath!,
        widget.message.type.value,
        extend: widget.message.extend,
      ).then((result) {
        if (result.code == 200 && result.success) {
          var errClients = <WSClient>[];
          var successClients = <WSClient>[];
          result.data.forEach((key, value) {
            if (value != null && _clientsMap.containsKey(key)) {
              errClients.add(_clientsMap[key]!);
            } else {
              successClients.add(_clientsMap[key]!);
            }
          });
          setState(() => _isLoading = false);
          // 存在发送失败的用户
          if (errClients.isEmpty) {
            Navigator.pop(context, true);
          } else {
            setState(() {
              _clientsMap.clear();
              _crossFadeState = CrossFadeState.showFirst;
            });
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return SharedErrBottomSheet(
                  clients: errClients,
                  result: result.data,
                );
              },
            );
          }
          _saveToDatabase(receivers);
        } else {
          Navigator.pop(context, false);
        }
      });
    }
  }

  void _saveToDatabase(List<String> receivers) async {
    for (var receiver in receivers) {
      widget.message.receiver = receiver;
      await ChatRecordDbUtil.insertRecord(widget.message);
    }
  }

  void _handleSharedData() {
    showDialog(
      context: context,
      builder: (context) => SharedDialog(message: widget.message),
    ).then((value) {
      if (value) _handleUploadFile();
    });
  }

  Future<bool> _handleSysBack() async {
    if (_clientsMap.isNotEmpty) {
      setState(() {
        _clientsMap.clear();
        _crossFadeState = CrossFadeState.showFirst;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSysBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            await WSClientManagement.instance.fetchClients();
          },
          child: Wrapper(
            isLoading: _isLoading,
            bdColor: _isSendingState
                ? const Color.fromRGBO(0, 0, 0, 0.2)
                : Colors.white,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  titleSpacing: 0,
                  title: AnimatedCrossFade(
                    firstChild: const Text("Select user"),
                    secondChild: Text("Selected ${_clientsMap.length} items"),
                    crossFadeState: _crossFadeState,
                    duration: const Duration(milliseconds: 400),
                  ),
                  leading: AnimatedCrossFade(
                    firstChild: Center(
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    secondChild: Center(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _crossFadeState = CrossFadeState.showFirst;
                            _clientsMap.clear();
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    crossFadeState: _crossFadeState,
                    duration: const Duration(milliseconds: 400),
                  ),
                  actions: [
                    AnimatedCrossFade(
                      firstChild: Container(),
                      secondChild: Center(
                        child: IconButton(
                          onPressed: () => _handleSharedData(),
                          icon: const Icon(Icons.share),
                        ),
                      ),
                      crossFadeState: _crossFadeState,
                      duration: const Duration(milliseconds: 400),
                    )
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItem(_clients[index], index),
                      childCount: _clients.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(WSClient client, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: _clientsMap.containsKey(client.uid)
            ? const Color(0xFFCFBCFF)
            : Colors.transparent,
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
      ),
      child: CustomFadeAnimation(
        key: ValueKey(client.uid),
        duration: const Duration(milliseconds: 300),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: AvatarComponent(
            client: client,
            selected: _clientsMap.containsKey(client.uid),
          ),
          title: Text(
            client.nickname,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF303133),
            ),
          ),
          onLongPress: () {
            if (!_clientsMap.containsKey(client.uid)) {
              setState(() {
                _clientsMap[client.uid] = client;
                _crossFadeState = CrossFadeState.showSecond;
              });
            } else if (_clientsMap.length > 1) {
              setState(() => _clientsMap.remove(client.uid));
            } else {
              setState(() {
                _clientsMap.remove(client.uid);
                _crossFadeState = CrossFadeState.showFirst;
              });
            }
          },
        ),
      ),
    );
  }

}
