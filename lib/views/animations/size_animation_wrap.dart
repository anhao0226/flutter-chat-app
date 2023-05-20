import 'package:flutter/material.dart';

class SizeAnimationWrap extends StatefulWidget {
  const SizeAnimationWrap({
    super.key,
    required this.child,
    required this.duration,
    required this.expand,
  });

  final bool expand;
  final Duration duration;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _SizeAnimationWrapState();
}

class _SizeAnimationWrapState extends State<SizeAnimationWrap>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant SizeAnimationWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expand != oldWidget.expand) {
      if (widget.expand) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedLogo(animation: _animation, child: widget.child);
}

class AnimatedLogo extends AnimatedWidget {
  const AnimatedLogo({
    super.key,
    required this.child,
    required Animation<double> animation,
  }) : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final animation = listenable as Animation<double>;
    return SizeTransition(
      axisAlignment: 0,
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Container(
        width: size.width,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: child,
      ),
    );
  }
}
