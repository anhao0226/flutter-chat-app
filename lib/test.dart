import 'dart:convert';

class Manager {
  static Manager? _instance;

  Manager._();

  factory Manager() {
    _instance ??= Manager._();
    return _instance!;
  }

  static Manager get instance => Manager();
}

class ToJson {

  String name = "";

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name": "zjh",
      "data": <String, dynamic>{
        "a": 1,
        "b": 2,
      }
    };
  }
}

void main() {

   var t = jsonEncode(ToJson().toMap());

   print(t);

  // // 无论如何初始化，取到的都是同一个对象
  // Manager manager1 = Manager();
  // Manager manager2 = Manager.instance;
  // Manager manager3 = Manager();
  // Manager manager4 = Manager.instance;
  // print(identical(manager1, manager2)); //true
  // print(identical(manager1, manager3)); //true
  // print(identical(manager3, manager4)); //true
}
