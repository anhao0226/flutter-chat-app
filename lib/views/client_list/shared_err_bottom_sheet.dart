import 'package:flutter/material.dart';
import '../../models/ws_client_model.dart';
import 'avatar_component.dart';

class SharedErrBottomSheet extends StatelessWidget {
  const SharedErrBottomSheet({
    super.key,
    required this.clients,
    required this.result,
  });

  final List<WSClient> clients;
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      constraints: const BoxConstraints(minHeight: 100.0, maxHeight: 200.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: AvatarComponent(
              client: clients[index],
              selected: false,
            ),
            title: Text(clients[index].nickname),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, color: Colors.redAccent, size: 14),
                const SizedBox(width: 4),
                Text(
                  result[clients[index].uid],
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
