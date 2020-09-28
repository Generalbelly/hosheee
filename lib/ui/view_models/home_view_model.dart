import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/ui/mixins/request_status_manager.dart';
import 'package:hosheee/ui/views/collections_view.dart';
import 'package:hosheee/ui/views/recent_view.dart';

class HomeViewModel extends ChangeNotifier with RequestStatusManager {

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  Auth _auth;

  User user;

  HomeViewModel(Auth auth) {
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

