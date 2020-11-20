import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hosheee/domain/models/setting.dart';
import 'package:hosheee/domain/use_cases/setting/add_setting_use_case.dart';
import 'package:hosheee/domain/use_cases/setting/get_setting_use_case.dart';
import 'package:hosheee/domain/use_cases/setting/update_setting_use_case.dart';

class SettingViewModel extends ChangeNotifier {

  String message;

  Setting setting = Setting(null);

  GetSettingUseCase _getSettingUseCase;
  AddSettingUseCase _addSettingUseCase;
  UpdateSettingUseCase _updateSettingUseCase;

  SettingViewModel(
    GetSettingUseCase getSettingUseCase,
    AddSettingUseCase addSettingUseCase,
    UpdateSettingUseCase updateSettingUseCase,
  ) {
    _getSettingUseCase = getSettingUseCase;
    _addSettingUseCase = addSettingUseCase;
    _updateSettingUseCase = updateSettingUseCase;
    getSetting();
  }

  void getSetting() async {
    final stream = _getSettingUseCase.handle(GetSettingUseCaseRequest());
    await for (var response in stream) {
      if (response.setting != null) {
        setting = response.setting;
        notifyListeners();
      }
    }
  }

  void saveThemeColor(Color color) async {
    setting.themeColor = color.value;
    if (setting.id == null) {
      final response = await _addSettingUseCase.handle(AddSettingUseCaseRequest(setting));
      message = response.message;
    } else {
      final response = await _updateSettingUseCase.handle(UpdateSettingUseCaseRequest(setting));
      message = response.message;
    }
    notifyListeners();
  }

  Color generateThemeColor() {
    return Color(setting.themeColor);
  }
}

