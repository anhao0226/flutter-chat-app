import 'package:flutter/material.dart';

import 'manage_local_image.dart';

class ManageLocalCacheView extends StatefulWidget {
  const ManageLocalCacheView({super.key});

  @override
  State<StatefulWidget> createState() => _ManageLocalCacheViewState();
}

class _ManageLocalCacheViewState extends State<ManageLocalCacheView> {
  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>['Image', 'Voice'];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return _buildHeader(context, innerBoxIsScrolled);
          },
          body: const TabBarView(
            children: [
              ManageLocalImageView(name: TabItems.image),
              ManageLocalImageView(name: TabItems.voice),
              // ManageLocalImageView(name: TabItems.voice),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeader(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          title: const Text('Manage local cache'),
          pinned: true,
          forceElevated: innerBoxIsScrolled,
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            // labelColor: Color(0xFF967ADC),
            indicatorColor: Color(0xFF909399),
            tabs: [
              Tab(
                icon: Icon(
                  Icons.picture_in_picture,
                  color: Color(0xFF909399),
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.voicemail_outlined,
                  color: Color(0xFF909399),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
