import 'package:desktop_app/utils/index.dart';
import 'package:flutter/material.dart';

class StatusBarComponent extends StatefulWidget {
  const StatusBarComponent({
    super.key,
    required this.isOpen,
    required this.text,
    this.actions = const [],
    this.onClose,
  });

  final bool isOpen;
  final String text;
  final VoidCallback? onClose;
  final List<Widget> actions;

  @override
  State<StatefulWidget> createState() => _StatusBarComponentState();
}

class _StatusBarComponentState extends State<StatusBarComponent> {
  bool _isOpen = false;

  @override
  void initState() {
    _isOpen = widget.isOpen;
    logger.i(_isOpen);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StatusBarComponent oldWidget) {
    if (widget.isOpen != oldWidget.isOpen) {
      setState(() => _isOpen = widget.isOpen);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
      child: Container(
        height: _isOpen ? 60 : 0,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.only(left: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F6FC),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: Color(0xFF606266),
                ),
              ),
            ),
            ...widget.actions,
            IconButton(
              onPressed: () {
                if (widget.onClose != null) {
                  setState(() => _isOpen = false);
                  widget.onClose!();
                }
              },
              icon: const Icon(
                Icons.close,
                color: Color(0xFF967ADC),
              ),
            )
          ],
        ),
      ),
    );
  }
}
