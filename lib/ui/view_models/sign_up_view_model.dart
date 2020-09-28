import 'package:flutter/foundation.dart';
import 'package:hosheee/ui/mixins/request_status_manager.dart';
import 'package:hosheee/utils/validator.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/use_cases/auth/sign_up_use_case.dart';

class SignUpViewModel extends ChangeNotifier {

  String _email;
  get email => _email;
  String emailErrorMessage;

  String _password;
  get password => _password;
  String passwordErrorMessage;

  String _passwordConfirmation;
  get passwordConfirmation => _passwordConfirmation;

  String message;
  User user;

  SignUpUseCase _signUpUseCase;

  RequestStatusManager requestStatusManager = RequestStatusManager();

  SignUpViewModel(this._signUpUseCase);

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

  set passwordConfirmation(String value) {
    _passwordConfirmation = value;
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
      'password_confirmation': passwordConfirmation,
    }, {
      'password': ['required', 'min:6', 'confirmed'],
    });
    final result = validator.validate()[0];
    passwordErrorMessage = result.valid ? null : result.messages[0];
    return result.valid;
  }

  void resetErrorMessages() {
    passwordErrorMessage = null;
    emailErrorMessage = null;
  }

  submit() async {
    final emailValid = validateEmail();
    final passwordValid = validatePassword();
    if (emailValid && passwordValid && !requestStatusManager.isLoading()) {
      user = null;
      message = null;
      requestStatusManager.loading();
      resetErrorMessages();
      final signUpUseCaseResponse = await _signUpUseCase.handle(
          SignUpUseCaseRequest(_email, _password));
      user = signUpUseCaseResponse.user;
      message = signUpUseCaseResponse.message;
      requestStatusManager.ok();
      notifyListeners();
    }
  }

}

