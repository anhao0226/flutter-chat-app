import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/my_app.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/views/animations/fade_animation.dart';
import 'package:flutter_chat_app/views/client_list/avatar_component.dart';
import 'package:flutter_chat_app/views/client_list/my_home_page.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/home_state_management.dart';
import '../../providers/ws_client_management.dart';

class ClientListView extends StatefulWidget {
  const ClientListView({super.key, required this.segment});

  final Segment segment;

  @override
  State<StatefulWidget> createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView>
    with AutomaticKeepAliveClientMixin {
  final _selectedItems = <WSClient>{};
  final bool _isLoading = false;

  @override
  void initState() {
    HomeStateManagement.instance.addListener(() {
      if (!HomeStateManagement.instance.isMultipleSelectState) {
        setState(() => _selectedItems.clear());
      }
    });
    super.initState();
  }

  void _handleItemTap(WSClient client) {
    if (HomeStateManagement.instance.segment == Segment.online) {
      context.push(RoutePaths.clientDetails, extra: client);
    } else {
      WSClientManagement.instance.enterChatStatus(client);
      context.push(RoutePaths.clientChatting, extra: client);
    }
  }

  void _handleItemLongPress(WSClient client) {
    if (_selectedItems.contains(client)) {
      setState(() => _selectedItems.remove(client));
      HomeStateManagement.instance.unselectedItem(client);
    } else {
      setState(() => _selectedItems.add(client));
      HomeStateManagement.instance.selectItem(client);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Wrapper(
      isLoading: _isLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          await WSClientManagement.instance.fetchClients();
        },
        child: Consumer<WSClientManagement>(
          builder: (context, value, child) {
            late List<WSClient> items;
            late Function renderListTileFn;
            if (widget.segment == Segment.message) {
              items = value.clientStates;
              renderListTileFn = _getMessageListTile;
            } else if (widget.segment == Segment.online) {
              items = value.clients;
              renderListTileFn = _getClientListTile;
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                return Container(
                  key: ValueKey(items[index].uid),
                  decoration: BoxDecoration(
                    color: _selectedItems.contains(items[index])
                        ? const Color(0xFFF2F6FC)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(14),
                    ),
                  ),
                  margin: const EdgeInsets.only(top: 4),
                  child: CustomFadeAnimation(
                    key: ValueKey(items[index]),
                    duration: const Duration(milliseconds: 300),
                    child: renderListTileFn(items[index]),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 0.6,
                  indent: 60,
                  color: Color(0xFFF2F6FC),
                );
              },
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }

  Widget _getClientListTile(WSClient client) {
    return ListTile(
      onTap: () => _handleItemTap(client),
      onLongPress: () => _handleItemLongPress(client),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: AvatarComponent(
        client: client,
        width: 36,
        height: 36,
        online: client.online,
        selected: _selectedItems.contains(client),
      ),
      title: Text(
        client.nickname,
        style: const TextStyle(fontSize: 18, color: Color(0xFF303133)),
      ),
    );
  }

  Widget _getMessageListTile(WSClient client) {
    return ListTile(
      onTap: () => _handleItemTap(client),
      onLongPress: () => _handleItemLongPress(client),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: AvatarComponent(
        client: client,
        width: 42,
        height: 42,
        online: client.online,
        selected: _selectedItems.contains(client),
      ),
      title: Text(
        client.nickname,
        style: const TextStyle(fontSize: 18, color: Color(0xFF303133)),
      ),
      subtitle: _getSubtitle(client),
      trailing: _getTrailingUI(client),
    );
  }

  Widget _getTrailingUI(WSClient client) {
    var components = <Widget>[
      Text(
        dateFormat(client.state!.lastMessageTime),
      ),
    ];
    if (client.state!.unreadMsgNum > 0) {
      components.add(Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Text(
          client.state!.unreadMsgNum.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ));
    }
    return Column(children: components);
  }

  Widget _getSubtitle(WSClient client) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        client.state!.lastMessageContent,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFA8ABB2),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
