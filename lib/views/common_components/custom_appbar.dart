import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
  });

  final Widget? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      elevation: 0,
      leadingWidth: 46,
      titleSpacing: 0,
      foregroundColor: const Color(0xFF656D78),
      leading: TextButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: const Icon(
          Icons.navigate_before,
          size: 28,
          color: Color(0xFF656D78),
        ),
      ),
      actions: actions,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kBottomNavigationBarHeight);
}
