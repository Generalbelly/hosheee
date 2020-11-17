import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/setting.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/setting_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class AddSettingUseCaseRequest {
  Setting setting;

  AddSettingUseCaseRequest(this.setting);

  Map<String, dynamic> toMap() {
    return {
      'setting': setting,
    };
  }
}

class AddSettingUseCaseResponse {
  String message;

  AddSettingUseCaseResponse({String message})
    : this.message = message;
}

class AddSettingUseCase {

  Auth _auth;

  SettingRepository _settingRepository;

  AddSettingUseCase(this._auth, this._settingRepository);

  Future<AddSettingUseCaseResponse> handle(AddSettingUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      request.setting.id = _settingRepository.nextIdentity();
      await _settingRepository.add(
          user.id,
          request.setting
      );
      return AddSettingUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return AddSettingUseCaseResponse(message: e.toString());
    }
  }

}
