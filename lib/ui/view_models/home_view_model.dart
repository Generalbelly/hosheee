import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/ui/mixins/request_status_manager.dart';
import 'package:hosheee/ui/views/collections_view.dart';
import 'package:hosheee/ui/views/recent_view.dart';

class HomeViewModel extends ChangeNotifier {

  List<Widget> contents = [];
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

  RequestStatusManager requestStatusManager = RequestStatusManager();

  HomeViewModel(
    Auth auth,
  ) {
    print("hosheee");
    _auth = auth;
    _auth.onAuthStateChanged(_handleAuthChange);
  }

  void _handleAuthChange(User u) {
    if (user == null && u != null) { // sign-in, sign-up時
      contents = <Widget>[
        RecentView(),
        CollectionsView(),
      ];
      user = u;
      notifyListeners();
    } else if (user != null && u == null) { // sign-out時
      user = u;
      notifyListeners();
    }
    requestStatusManager.ok();
  }

}

