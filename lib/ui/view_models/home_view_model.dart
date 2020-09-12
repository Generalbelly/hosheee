import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';
import 'package:wish_list/ui/views/collections_view.dart';
import 'package:wish_list/ui/views/recent_view.dart';

class HomeViewModel extends ChangeNotifier with RequestStatusManager {

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  Auth _auth;
  User user;
  List<Product> products = [];
  List<Collection> collections = [];

  String message;

  HomeViewModel(
    Auth auth,
  ) {
    _auth = auth;
    _auth.onAuthStateChanged(_handleAuthChange);
  }

  void _handleAuthChange(dynamic u) {
    user = u;
    if (user != null) {
      print(user.email);
      print("authenticated");
    } else {
      print("not authenticated");
    }
    ok();
    notifyListeners();
  }

  final List<Widget> contents = <Widget>[
    RecentView(),
    CollectionsView(),
  ];

}

