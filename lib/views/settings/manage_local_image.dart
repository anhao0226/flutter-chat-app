import 'dart:io';

import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/route.dart';
import 'package:flutter_chat_app/views/animations/fade_animation.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter_chat_app/views/image_view.dart';
import 'package:flutter/material.dart';

enum TabItems { voice, image }

class ManageLocalImageView extends StatefulWidget {
  const ManageLocalImageView({super.key, required this.name});

  final TabItems name;

  @override
  State<StatefulWidget> createState() => _ManageLocalImageViewState();
}

class _FileWrap {
  bool checked;
  late FileSystemEntity file;

  _FileWrap(this.file, this.checked);
}

class _ManageLocalImageViewState extends State<ManageLocalImageView> {
  final _files = <_FileWrap>[];

  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    _isLoading = true;
    _handleLocalCache();
    super.initState();
  }

  void _handleLocalCache() async {
    late Directory curr;
    switch (widget.name) {
      case TabItems.image:
        curr = Initialization.pictureSaveDir;
        break;
      case TabItems.voice:
        curr = Initialization.voiceSaveDir;
        break;
    }

    var files = await curr.list().toList();
    for (var element in files) {
      _files.add(_FileWrap(element, false));
    }
    await Future.delayed(const Duration(seconds: 1));
    if (!_isDisposed) {
      setState(() => _isLoading = false);
    }
  }

  String _filename(String name) {
    int lastIndex = name.lastIndexOf("/") + 1;
    return name.substring(lastIndex);
  }

  void _handleItemTap(_FileWrap value) {
    switch (widget.name) {
      case TabItems.voice:
        break;
      case TabItems.image:
        Navigator.push(
          context,
          SlideRightRoute(
            page: ImageView(
              filepath: value.file.path,
              onDelete: (value) {
                _showDeleteDialog();
              },
            ),
          ),
        );
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete this file?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Done"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      isLoading: _isLoading,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: PageStorageKey<TabItems>(widget.name),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildItem(_files[index]);
                  },
                  childCount: _files.length,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(_FileWrap value) {
    var stat = value.file.statSync();
    return CustomFadeAnimation(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: ListTile(
          onTap: () => _handleItemTap(value),
          leading: _getImageUI(value.file.path),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _filename(value.file.path),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    dateFormat(stat.modified),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${stat.size} bytes',
                    style: const TextStyle(fontSize: 14),
                  )
                ],
              )
            ],
          ),
          trailing: _getTrailingUI(),
        ),
      ),
    );
  }

  Widget _getTrailingUI() {
    return const Icon(Icons.navigate_next);
  }

  Widget _getImageUI(String path) {
    late Widget child;
    switch (widget.name) {
      case TabItems.image:
        child = Image.file(File(path), fit: BoxFit.cover, cacheWidth: 80);
        break;
      default:
        child = const Icon(Icons.voicemail_outlined);
        break;
    }
    return Container(
      width: 42,
      height: 42,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: child,
    );
  }
}
