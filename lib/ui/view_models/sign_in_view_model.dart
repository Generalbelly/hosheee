import 'package:flutter/foundation.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/ui/mixins/request_status_manager.dart';
import 'package:wish_list/utils/validator.dart';
import 'package:wish_list/domain/use_cases/auth/sign_in_use_case.dart';

class SignInViewModel extends ChangeNotifier {

  String _email;
  get email => _email;
  String emailErrorMessage;

  String _password;
  get password => _password;
  String passwordErrorMessage;

  String message;
  User user;

  SignInUseCase _signInUseCase;

  RequestStatusManager requestStatusManager = RequestStatusManager();

  SignInViewModel(this._signInUseCase);

  set email(String value) {
    _email = value;
    validateEmail();
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    validatePassword();
    notifyListeners();
  }

  bool validateEmail() {
    final validator = Validator({
      'email': email,
    }, {
      'email': ['required', 'email'],
    });
    final result = validator.validate()[0];
    emailErrorMessage = result.valid ? null : result.messages[0];
    return result.valid;
  }

  bool validatePassword() {
    final validator = Validator({
      'password': password,
    }, {
      'password': ['required'],
    });
    final result = validator.validate()[0];
    passwordErrorMessage = result.valid ? null : result.messages[0];
    return result.valid;
  }

  submit() async {
    final emailValid = validateEmail();
    final passwordValid = validatePassword();
    if (emailValid && passwordValid && !requestStatusManager.isLoading()) {
      user = null;
      message = null;
      requestStatusManager.loading();
      final signInUseCaseResponse = await _signInUseCase.handle(
          SignInUseCaseRequest(email, password));
      user = signInUseCaseResponse.user;
      message = signInUseCaseResponse.message;
      requestStatusManager.ok();
      notifyListeners();
    }
  }

}

