import 'package:wish_list/domain/models/auth.dart';

class SignUpUseCaseRequest {
  String email;
  String password;

  SignUpUseCaseRequest(this.email, this.password);
}

class SignUpUseCaseResponse {
  dynamic user;
  String message;

  SignUpUseCaseResponse(this.user, {String message})
    : this.message = message;
}

class SignUpUseCase {

  Auth _authService;

  SignUpUseCase(this._authService);

  Future<SignUpUseCaseResponse> handle(SignUpUseCaseRequest request) async {
    var message = 'An unexpected error happened.';
    try {
      final user = await _authService.signUpWithEmail(request.email, request.password);
      if (user != null) {
        return SignUpUseCaseResponse(user);
      }
    } catch (error) {
      print(error);
      message = error.toString();
    }
    return SignUpUseCaseResponse(null, message: message);
  }

}
