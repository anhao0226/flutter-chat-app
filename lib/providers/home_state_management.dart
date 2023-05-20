import 'package:desktop_app/models/ws_client_model.dart';
import 'package:desktop_app/providers/ws_client_management.dart';
import 'package:flutter/cupertino.dart';

import '../views/client_list/my_home_page.dart';

class HomeStateManagement extends ChangeNotifier {
  HomeStateManagement._();

  static HomeStateManagement? _instance;

  static HomeStateManagement get instance => HomeStateManagement();

  factory HomeStateManagement() {
    _instance ??= HomeStateManagement._();
    return _instance!;
  }

  Segment _currSegment = Segment.message;

  final showDot = <Segment, bool>{
    Segment.online: false,
    Segment.message: false,
  };


  bool isMultipleSelectState = false;

  final selectedItems = <WSClient>{};

  void selectItem(WSClient client) {
    selectedItems.add(client);
    isMultipleSelectState = true;
    notifyListeners();
  }

  void unselectedItem(WSClient client) {
    selectedItems.remove(client);
    if (selectedItems.isEmpty) isMultipleSelectState = false;
    notifyListeners();
  }

  void clearSelectedItems() {
    if (_currSegment == Segment.message) {
      WSClientManagement.instance.clearClientState(selectedItems.toList());
    } else if (_currSegment == Segment.online) {
      //
    }
    isMultipleSelectState = false;
    selectedItems.clear();
    notifyListeners();
  }

  void currMultipleSelectState(bool value) {
    if (isMultipleSelectState != value) {
      isMultipleSelectState = value;
      if (!value) selectedItems.clear();
      notifyListeners();
    }
  }

  void showSegmentDot(Segment value) {
    if (value != _currSegment) {
      showDot[value] = true;
      notifyListeners();
    }
  }

  void currSegment(Segment value) {
    _currSegment = value;
    showDot[value] = false;
    isMultipleSelectState = false;
    selectedItems.clear();
    notifyListeners();
  }
}
