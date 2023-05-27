import 'package:flutter_chat_app/providers/ws_client_management.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/views/client_list/avatar_component.dart';
import 'package:flutter_chat_app/views/client_list/status_bar.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/home_state_management.dart';
import '../../utils/iconfont.dart';
import '../../router/router.dart';
import '../../utils/websocket.dart';
import 'client_list_view.dart';

enum Segment { message, online }

class MyHomeView extends StatefulWidget {
  const MyHomeView({super.key});

  @override
  State<MyHomeView> createState() => _MyHomeViewState();
}

class _MyHomeViewState extends State<MyHomeView> {
  Segment _selectedSegment = Segment.message;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    await WSClientManagement.instance.fetchClients();
  }

  void _onPageChanged(int value) {
    if (value == 0) {
      setState(() => _selectedSegment = Segment.message);
      HomeStateManagement.instance.currSegment(Segment.message);
    } else if (value == 1) {
      setState(() => _selectedSegment = Segment.online);
      HomeStateManagement.instance.currSegment(Segment.online);
    }
  }

  void _selectedChange(Segment value) {
    HomeStateManagement.instance.currSegment(value);
    if (value == Segment.message) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 412),
        curve: Curves.easeInOut,
      );
    } else if (value == Segment.online) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 412),
        curve: Curves.easeInOut,
      );
    }
    setState(() => _selectedSegment = value);
  }

  void _showDeleteDialog(BuildContext context) async {
    var isDeleted = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete ?"),
          content: const Text("Are you sure to delete the selected users ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Done"),
            )
          ],
        );
      },
    );
    if (!mounted) return;
    if (isDeleted) {
      HomeStateManagement.instance.clearSelectedItems();
    } else {
      HomeStateManagement.instance.currMultipleSelectState(false);
    }
  }

  Future<bool> _handleSysBack() async {
    if (HomeStateManagement.instance.selectedItems.isNotEmpty) {
      HomeStateManagement.instance.currMultipleSelectState(false);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSysBack,
      child: _getClientList(),
    );
  }

  Widget _getClientList() {
    var selectedItems = context.watch<HomeStateManagement>().selectedItems;
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     // context.push(RoutePaths.amap);
      //   },
      //   child: const Icon(Icons.map),
      // ),
      appBar: AppBar(
        leadingWidth: kToolbarHeight + 14,
        leading: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 14),
          child: AnimatedCrossFade(
            alignment: Alignment.center,
            crossFadeState: selectedItems.isEmpty
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: SizedBox(
              height: kToolbarHeight,
              child: ValueListenableBuilder(
                valueListenable: WSUtil.instance.connectivity,
                builder: (context, value, child) {
                  return Center(
                    child: AvatarComponent(
                      width: 36.0,
                      height: 36.0,
                      client: Initialization.client!,
                      selected: false,
                      online: value,
                    ),
                  );
                },
              ),
            ),
            secondChild: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  HomeStateManagement.instance.currMultipleSelectState(false);
                },
                icon: const Icon(Iconfonts.close, size: 24),
              ),
            ),
            duration: const Duration(milliseconds: 412),
          ),
        ),
        centerTitle: true,
        title: AnimatedCrossFade(
          alignment: Alignment.center,
          firstChild: const SizedBox(),
          secondChild: Text("Selected ${selectedItems.length} items"),
          crossFadeState: selectedItems.isEmpty
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 412),
        ),
        actions: [
          AnimatedCrossFade(
            firstChild: IconButton(
              onPressed: () {
                context.push(RoutePaths.settings);
              },
              icon: const Icon(Iconfonts.setting, size: 24),
            ),
            secondChild: IconButton(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Iconfonts.clear, size: 24),
            ),
            crossFadeState: selectedItems.isEmpty
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 400),
          ),
          const SizedBox(width: 10)
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76.0),
          child: Container(
            height: 76.0,
            alignment: Alignment.center,
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: _getCupertinoSlidingSegmentedControl(),
            ),
          ),
        ),
      ),
      body: Wrapper(
        isLoading: false,
        stack: [
          ValueListenableBuilder(
            valueListenable: WSUtil.instance.connectivity,
            builder: (context, value, child) {
              return StatusBarComponent(isOpen: value);
            },
          ),
        ],
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            ClientListView(segment: Segment.message),
            ClientListView(segment: Segment.online),
          ],
        ),
      ),
    );
  }

  Widget _getCupertinoSlidingSegmentedControl() {
    var showDot = context.watch<HomeStateManagement>().showDot;
    return CupertinoSlidingSegmentedControl<Segment>(
      thumbColor: Colors.white,
      groupValue: _selectedSegment,
      onValueChanged: (Segment? value) {
        if (value != null) {
          _selectedChange(value);
        }
      },
      children: <Segment, Widget>{
        Segment.message: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: badges.Badge(
            showBadge: showDot[Segment.message]!,
            position: badges.BadgePosition.topStart(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Iconfonts.message),
                SizedBox(width: 10),
                Text('Messages'),
              ],
            ),
          ),
        ),
        Segment.online: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: badges.Badge(
            showBadge: showDot[Segment.online]!,
            position: badges.BadgePosition.topStart(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Iconfonts.user),
                SizedBox(width: 10),
                Text('Clients'),
              ],
            ),
          ),
        ),
      },
    );
  }
}
