import 'package:desktop_app/utils/route.dart';
import 'package:flutter/material.dart';

enum ActionType {
  delete("Delete", Icons.delete),
  shared("Shared", Icons.share),
  multiple("Multiple", Icons.library_add_check),
  send("Resend", Icons.send),
  copy("Copy", Icons.copy);

  const ActionType(this.label, this.iconData);

  final String label;

  final IconData iconData;
}

class ActionsBottomSheet extends StatefulWidget {
  const ActionsBottomSheet({
    super.key,
    required this.actions,
  });

  final List<ActionType> actions;

  @override
  State<StatefulWidget> createState() => _ActionsBottomSheetState();
}

class _ActionsBottomSheetState extends State<ActionsBottomSheet> {
  CrossFadeState _crossFadeState = CrossFadeState.showFirst;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      alignment: Alignment.center,
      firstChild: _getDefaultUI(),
      secondChild: _getConfirmUI(),
      firstCurve: Curves.ease,
      secondCurve: Curves.ease,
      sizeCurve: Curves.ease,
      crossFadeState: _crossFadeState,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _getDefaultUI() {
    var actions = <Widget>[];
    for (var element in widget.actions) {
      switch (element) {
        case ActionType.send:
        case ActionType.copy:
        case ActionType.shared:
        case ActionType.multiple:
          actions.add(
            _buildItem(
              label: element.label,
              iconData: element.iconData,
              onPressed: () => Navigator.pop(context, element),
            ),
          );
          break;
        case ActionType.delete:
          actions.add(_buildItem(
            label: "Delete",
            color: Colors.white,
            bgColor: Colors.redAccent,
            iconData: Icons.delete,
            onPressed: () {
              setState(() => _crossFadeState = CrossFadeState.showSecond);
            },
          ));
          break;
      }
    }

    return Container(
      height: 112.0,
      alignment: Alignment.center,
      color: const Color(0xFFF0F2F5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: actions,
      ),
    );
  }

  Widget _getConfirmUI() {
    return Container(
      height: 112.0,
      alignment: Alignment.center,
      color: const Color(0xFFF0F2F5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildItem(
            label: "Cancel",
            iconData: Icons.close,
            onPressed: () => Navigator.pop(context),
          ),
          _buildItem(
            label: "Ok",
            iconData: Icons.check,
            onPressed: () => Navigator.pop(context, ActionType.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String label,
    required VoidCallback onPressed,
    required IconData iconData,
    Color color = Colors.black,
    Color bgColor = Colors.white,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(iconData, color: color),
          ),
        ),
        const SizedBox(height: 10),
        Text(label)
      ],
    );
  }
}
