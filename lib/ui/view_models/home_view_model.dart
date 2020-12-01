import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:hosheee/ad/ad_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/setting.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/use_cases/setting/add_setting_use_case.dart';
import 'package:hosheee/domain/use_cases/setting/get_setting_use_case.dart';
import 'package:hosheee/domain/use_cases/setting/update_setting_use_case.dart';
import 'package:hosheee/ui/common/request_status_manager.dart';
import 'package:hosheee/ui/views/collections_view.dart';
import 'package:hosheee/ui/views/products_view.dart';
import 'package:hosheee/ui/views/setting_view.dart';

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

  BannerAd _bannerAd;
  bool isAdShown = false;

  Setting setting = Setting(null);

  int previousThemeColorValue;

  GetSettingUseCase _getSettingUseCase;
  AddSettingUseCase _addSettingUseCase;
  UpdateSettingUseCase _updateSettingUseCase;

  HomeViewModel(
    Auth auth,
    GetSettingUseCase getSettingUseCase,
    AddSettingUseCase addSettingUseCase,
    UpdateSettingUseCase updateSettingUseCase,
  ) {
    _auth = auth;
    _auth.onAuthStateChanged(_handleAuthChange);
    _getSettingUseCase = getSettingUseCase;
    _addSettingUseCase = addSettingUseCase;
    _updateSettingUseCase = updateSettingUseCase;
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
          size: AdSize.fullBanner,
        );
      }
      _bannerAd
        ..load()
        ..show(anchorType: AnchorType.top);
      isAdShown = true;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await hideBannerAd();
  }

  Future<void> hideBannerAd() async {
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
        SettingView(),
      ];
      selectedIndex = 0;
      user = u;
      showBannerAd();

      // 少し置いてから取得しに行かないとauthエラーになることがある。
      Timer(Duration(seconds: 1), () {
        getSetting();
      });
    } else if (user != null && u == null) { // sign-out時
      user = u;
    }
    notifyListeners();
  }

  void getSetting() async {
    final stream = _getSettingUseCase.handle(GetSettingUseCaseRequest());
    await for (var response in stream) {
      if (response.message != null) {
        message = response.message;
      } else if (response.setting != null) {
        setting = response.setting;
      }
      notifyListeners();
    }
  }

  setThemeColor(int value) async {
    setting.themeColor = value;
    notifyListeners();
  }

  Future<void> saveSetting() async {
    if (setting.id == null) {
      final response = await _addSettingUseCase.handle(AddSettingUseCaseRequest(setting));
      message = response.message;
    } else {
      final response = await _updateSettingUseCase.handle(UpdateSettingUseCaseRequest(setting));
      message = response.message;
    }
    if (message != null) {
      notifyListeners();
    }
  }

  Color generateThemeColor() {
    return Color(setting.themeColor);
  }

}

