import 'package:flutter/material.dart';

class RequestPermissionView extends StatelessWidget {
  const RequestPermissionView({
    super.key,
    required this.title,
    required this.describe,
  });

  final String title;
  final String describe;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            child: Image.asset(
              'assets/icons/permissions.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 20),
          Text(describe),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(
            'Deny',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context, true);
          },
          child: Text(
            'Allow',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.deepPurple),
          ),
        ),
      ],
    );
  }
}
