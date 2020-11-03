import 'package:firebase_admob/firebase_admob.dart';
import 'package:hosheee/ad/ad_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';
import 'package:hosheee/ui/views/collections_view.dart';
import 'package:hosheee/ui/views/products_view.dart';

class HomeViewModel extends ChangeNotifier {

  List<Widget> contents = [];
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    if (value == 0) {
      showBannerAd();
    } else {
      hideBannerAd();
    }
    notifyListeners();
  }

  Auth _auth;
  User user;
  List<Product> products = [];
  List<Collection> collections = [];

  String message;

  RequestStatusManager requestStatusManager = RequestStatusManager();

  BannerAd _bannerAd;
  bool isAdShown = false;

  HomeViewModel(
    Auth auth,
  ) {
    _auth = auth;
    _auth.onAuthStateChanged(_handleAuthChange);
    showBannerAd();
  }

  @override
  void dispose() {
    hideBannerAd();
    super.dispose();
  }

  Future<void> showBannerAd() async {
    if (!isAdShown) {
      if (_bannerAd == null) {
        _bannerAd = BannerAd(
          adUnitId: AdManager.bannerAdUnitId,
          size: AdSize.banner,
        );
      }
      _bannerAd
        ..load()
        ..show(anchorType: AnchorType.bottom, anchorOffset: 75);
      isAdShown = true;
    }
  }

  void hideBannerAd() async {
    if (isAdShown) {
      await _bannerAd.dispose();
      _bannerAd = null;
      isAdShown = false;
    }
  }

  void _handleAuthChange(User u) {
    requestStatusManager.ok();
    if (user == null && u != null) { // sign-in, sign-up時
      contents = <Widget>[
        ProductsView(),
        CollectionsView(),
      ];
      user = u;
    } else if (user != null && u == null) { // sign-out時
      user = u;
    }
    notifyListeners();
  }

}

