import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({
    super.key,
    required this.child,
    required this.isLoading,
    this.stack = const [],
    this.bdColor = Colors.white,
  });

  final bool isLoading;
  final Widget child;
  final List<Widget> stack;
  final Color bdColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        child,
        ...stack,
        isLoading ? _getLoadingUI() : Container(),
      ],
    );
  }

  Widget _getLoadingUI() {
    return Container(
      color: bdColor,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
