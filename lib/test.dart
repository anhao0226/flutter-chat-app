import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Global {
  static int _id = 0;

  static int get id => _id;

  static void doCount() {
    _id++;
  }
}

class P extends ChangeNotifier {
  int get count => Global.id;
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Global.doCount();
        },
      ),
      body: Center(
        child: Text(context.read<P>().count.toString()),
      ),
    );
  }
}
