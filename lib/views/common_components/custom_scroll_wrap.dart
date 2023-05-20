import 'package:flutter/material.dart';

class CustomScrollWrapper extends StatefulWidget {
  const CustomScrollWrapper({
    super.key,
    this.isLoading = false,
    this.slivers = const [],
    this.children = const [],
    this.tipsContent,
    this.showTips = false,
    this.tipsActions = const [],
    this.onCloseTips,
    this.controller,
    this.center,
  });

  final Key? center;
  final bool isLoading;
  final List<Widget> slivers;
  final List<Widget> children;
  final ScrollController? controller;

  final bool showTips;
  final String? tipsContent;
  final List<Widget> tipsActions;
  final VoidCallback? onCloseTips;

  @override
  State<StatefulWidget> createState() => _CustomScrollWrapperState();
}

class _CustomScrollWrapperState extends State<CustomScrollWrapper> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CustomScrollView(
          center: widget.center,
          controller: widget.controller,
          physics: const BouncingScrollPhysics(),
          slivers: [_getTipsUI(), ...widget.slivers],
        ),
        ...widget.children,
        widget.isLoading ? _getLoadingUI() : Container(),
      ],
    );
  }

  Widget _getTipsUI() {
    return SliverToBoxAdapter(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        child: Container(
          height: widget.showTips ? 50 : 0,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.tipsContent ?? ""),
              IconButton(
                onPressed: () {
                  // if (onCloseTips != null) onCloseTips!();
                },
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLoadingUI() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
