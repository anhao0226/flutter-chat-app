import 'package:flutter/material.dart';

class CustomFadeAnimation extends StatefulWidget {
  const CustomFadeAnimation({
    super.key,
    required this.child,
    required this.duration,
  });

  final Duration duration;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _CustomFadeAnimationState();
}

class _CustomFadeAnimationState extends State<CustomFadeAnimation>
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
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant CustomFadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: size.width,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
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
