import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/setting.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/setting_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class GetSettingUseCaseRequest {
  GetSettingUseCaseRequest();
}

class GetSettingUseCaseResponse {
  String message;
  Setting setting;

  GetSettingUseCaseResponse(this.setting, {String message})
    : this.message = message;
}

class GetSettingUseCase {

  Auth _auth;

  SettingRepository _settingRepository;

  GetSettingUseCase(this._auth, this._settingRepository);

  Stream<GetSettingUseCaseResponse> handle(GetSettingUseCaseRequest request) async* {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      final stream = _settingRepository.get(
          user.id,
      );
      await for (var setting in stream) {
        yield GetSettingUseCaseResponse(setting);
      }
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toString(),
      });
      yield GetSettingUseCaseResponse(null, message: e.toString());
    }
  }

}
