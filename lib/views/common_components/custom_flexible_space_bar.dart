import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MyAppSpace extends StatefulWidget {
  const MyAppSpace(
      {super.key,
      this.title,
      this.background,
      this.centerTitle,
      this.titlePadding,
      this.collapseMode = CollapseMode.parallax,
      this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
      this.expandedTitleScale = 1.5,
      this.onEnd});

  /// The primary contents of the flexible space bar when expanded.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Shown behind the [title] when expanded.
  ///
  /// Typically an [Image] widget with [Image.fit] set to [BoxFit.cover].
  final Widget? background;

  /// Whether the title should be centered.
  ///
  /// By default this property is true if the current target platform
  /// is [TargetPlatform.iOS] or [TargetPlatform.macOS], false otherwise.
  final bool? centerTitle;

  /// Collapse effect while scrolling.
  ///
  /// Defaults to [CollapseMode.parallax].
  final CollapseMode collapseMode;

  /// Stretch effect while over-scrolling.
  ///
  /// Defaults to include [StretchMode.zoomBackground].
  final List<StretchMode> stretchModes;

  /// Defines how far the [title] is inset from either the widget's
  /// bottom-left or its center.
  ///
  /// Typically this property is used to adjust how far the title is
  /// is inset from the bottom-left and it is specified along with
  /// [centerTitle] false.
  ///
  /// By default the value of this property is
  /// `EdgeInsetsDirectional.only(start: 72, bottom: 16)` if the title is
  /// not centered, `EdgeInsetsDirectional.only(start: 0, bottom: 16)` otherwise.
  final EdgeInsetsGeometry? titlePadding;

  /// Defines how much the title is scaled when the FlexibleSpaceBar is expanded
  /// due to the user scrolling downwards. The title is scaled uniformly on the
  /// x and y axes while maintaining its bottom-left position (bottom-center if
  /// [centerTitle] is true).
  ///
  /// Defaults to 1.5 and must be greater than 1.
  final double expandedTitleScale;

  final VoidCallback? onEnd;

  @override
  State<StatefulWidget> createState() => _MyAppSpaceState();
}

class _MyAppSpaceState extends State<MyAppSpace>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  bool _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) {
      return widget.centerTitle!;
    }
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) {
      return Alignment.bottomCenter;
    }
    final TextDirection textDirection = Directionality.of(context);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final double deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 360),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
      reverseCurve: Curves.ease,
    ));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnimation(bool show) {
    if (_animationController.isAnimating) {
      _animationController.stop();
      if (show) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    } else if (_animationController.isDismissed && show) {
      _animationController.forward();
    } else if (_animationController.isCompleted && !show) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ClipRect(
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final settings = context.dependOnInheritedWidgetOfExactType<
                  FlexibleSpaceBarSettings>()!;
              final double deltaExtent =
                  settings.maxExtent - settings.minExtent;
              final double t = clampDouble(
                1.0 -
                    (settings.currentExtent - settings.minExtent) / deltaExtent,
                0.0,
                1.0,
              );

              final List<Widget> children = <Widget>[];

              // background
              if (widget.background != null) {
                final double fadeStart =
                    math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
                const double fadeEnd = 1.0;
                assert(fadeStart <= fadeEnd);
                // If the min and max extent are the same, the app bar cannot collapse
                // and the content should be visible, so opacity = 1.
                final double opacity = settings.maxExtent == settings.minExtent
                    ? 1.0
                    : 1.0 - Interval(fadeStart, fadeEnd).transform(t);
                double height = settings.maxExtent;

                // StretchMode.zoomBackground
                if (widget.stretchModes.contains(StretchMode.zoomBackground) &&
                    constraints.maxHeight > height) {
                  height = constraints.maxHeight;
                }
                children.add(
                  Positioned(
                    top: _getCollapsePadding(t, settings),
                    left: 0.0,
                    right: 0.0,
                    height: height,
                    child: Opacity(
                      // IOS is relying on this semantics node to correctly traverse
                      // through the app bar when it is collapsed.
                      alwaysIncludeSemantics: true,
                      opacity: opacity,
                      child: widget.background,
                    ),
                  ),
                );

                // StretchMode.blurBackground
                if (widget.stretchModes.contains(StretchMode.blurBackground) &&
                    constraints.maxHeight > settings.maxExtent) {
                  final double blurAmount =
                      (constraints.maxHeight - settings.maxExtent) / 10;
                  children.add(Positioned.fill(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: blurAmount,
                        sigmaY: blurAmount,
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ));
                }
              }

              // title
              if (widget.title != null) {
                Widget? title;
                switch (theme.platform) {
                  case TargetPlatform.iOS:
                  case TargetPlatform.macOS:
                    title = widget.title;
                    break;
                  case TargetPlatform.android:
                  case TargetPlatform.fuchsia:
                  case TargetPlatform.linux:
                  case TargetPlatform.windows:
                    title = Semantics(
                      namesRoute: true,
                      child: widget.title,
                    );
                    break;
                }

                // StretchMode.fadeTitle
                if (widget.stretchModes.contains(StretchMode.fadeTitle) &&
                    constraints.maxHeight > settings.maxExtent) {
                  final double stretchOpacity = 1 -
                      clampDouble(
                          (constraints.maxHeight - settings.maxExtent) / 100,
                          0.0,
                          1.0);
                  title = Opacity(
                    opacity: stretchOpacity,
                    child: title,
                  );
                }

                final double opacity = settings.toolbarOpacity;
                if (opacity > 0.0) {
                  TextStyle titleStyle = theme.primaryTextTheme.titleLarge!;
                  titleStyle = titleStyle.copyWith(
                    color: titleStyle.color!.withOpacity(opacity),
                  );

                  if (t > 0.5 && _animation.isDismissed) {
                    _handleAnimation(true);
                  } else if (t <= 0.5 && _animation.isCompleted) {
                    _handleAnimation(false);
                  } else if (_animationController.isAnimating) {
                    // _animationController.stop();
                    // _animationController.isAnimating
                  }

                  final bool effectiveCenterTitle =
                      _getEffectiveCenterTitle(theme);

                  final Alignment titleAlignment =
                      _getTitleAlignment(effectiveCenterTitle);

                  final EdgeInsetsGeometry padding = widget.titlePadding ??
                      EdgeInsetsDirectional.only(
                        start: effectiveCenterTitle ? 0.0 : 72.0,
                        bottom: 16.0,
                      );
                  children.add(
                    Opacity(
                      opacity: 1 - t,
                      child: Align(
                        alignment: titleAlignment,
                        child: Container(
                          padding: padding,
                          color: Colors.white,
                          alignment: Alignment.bottomLeft,
                          child: DefaultTextStyle(
                            style: titleStyle.copyWith(
                              fontSize: widget.expandedTitleScale *
                                  titleStyle.fontSize!,
                            ),
                            child: title!,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
              return ClipRect(child: Stack(children: children));
            },
          ),
          Container(
            height: 80.0,
            width: double.maxFinite,
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: FadeTransition(
              opacity: _animation,
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.titleLarge!,
                child: Container(
                  alignment: Alignment.center,
                  height: 56,
                  child: widget.title!,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// if (opacity > 0.0) {
//   TextStyle titleStyle = theme.primaryTextTheme.titleLarge!;
//   titleStyle = titleStyle.copyWith(
//     color: titleStyle.color!.withOpacity(opacity),
//   );
//   final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme);
//   final EdgeInsetsGeometry padding = widget.titlePadding ??
//       EdgeInsetsDirectional.only(
//         start: effectiveCenterTitle ? 0.0 : 72.0,
//         bottom: 16.0,
//       );
//   final double scaleValue =
//       Tween<double>(begin: widget.expandedTitleScale, end: 1)
//           .transform(t);
//
//   final Matrix4 scaleTransform = Matrix4.identity()
//     ..scale(scaleValue, scaleValue, 1.0);
//   final Alignment titleAlignment =
//       _getTitleAlignment(effectiveCenterTitle);
//   children.add(
//     Container(
//       padding: padding,
//       child: Transform(
//         alignment: titleAlignment,
//         transform: scaleTransform,
//         child: Align(
//           alignment: titleAlignment,
//           child: DefaultTextStyle(
//             style: titleStyle,
//             child: LayoutBuilder(
//               builder:
//                   (BuildContext context, BoxConstraints constraints) {
//                 return Container(
//
//                   width: constraints.maxWidth / scaleValue,
//                   alignment: titleAlignment,
//                   child: title,
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }
