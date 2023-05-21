import 'package:flutter_chat_app/utils/dio_instance.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter/material.dart';

import '../../utils/iconfont.dart';

class PickerAvatarView extends StatefulWidget {
  const PickerAvatarView({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.icons,
  });

  final Function(String avatarUrl) onNext;
  final VoidCallback onBack;
  final List<ServerIconData> icons;

  @override
  State<StatefulWidget> createState() => _PickerAvatarViewState();
}

class _PickerAvatarViewState extends State<PickerAvatarView> {
  String _selectedAvatar = "";
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Picker avatar"),
        leading: IconButton(
          onPressed: () => widget.onBack(),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        actions: [
          TextButton(
            onPressed: () => widget.onNext(_selectedAvatar),
            child: const Text("Done"),
          )
        ],
      ),
      body: Wrapper(
        isLoading: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                onLongPress: () {
                  setState(() {
                    _selectedAvatar = widget.icons[index].src;
                    _selectedIndex = index;
                  });
                },
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.network(
                          widget.icons[index].src,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    AnimatedSize(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: _selectedIndex == index ? double.infinity : 0,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6750A4),
                            borderRadius: BorderRadius.all(Radius.circular(23)),
                          ),
                          child: const Icon(
                            Iconfonts.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: widget.icons.length,
          ),
        ),
      ),
    );
  }
}
