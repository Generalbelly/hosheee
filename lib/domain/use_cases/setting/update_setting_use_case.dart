import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/setting.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/setting_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class UpdateSettingUseCaseRequest {
  Setting setting;

  UpdateSettingUseCaseRequest(this.setting);

  Map<String, dynamic> toMap() {
    return {
      'setting': setting,
    };
  }
}

class UpdateSettingUseCaseResponse {
  String message;

  UpdateSettingUseCaseResponse({String message})
    : this.message = message;
}

class UpdateSettingUseCase {

  Auth _auth;

  SettingRepository _settingRepository;

  UpdateSettingUseCase(this._auth, this._settingRepository);

  Future<UpdateSettingUseCaseResponse> handle(UpdateSettingUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _settingRepository.update(
          user.id,
          request.setting
      );
      return UpdateSettingUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return UpdateSettingUseCaseResponse(message: e.toString());
    }
  }

}
