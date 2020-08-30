import 'package:wish_list/domain/models/auth.dart';

class SignInUseCaseRequest {
  String email;
  String password;

  SignInUseCaseRequest(this.email, this.password);
}

class SignInUseCaseResponse {
  dynamic user;
  String message;

  SignInUseCaseResponse(this.user, {String message})
    : this.message = message;
}

class SignInUseCase {

  Auth _authService;

  SignInUseCase(this._authService);

  Future<SignInUseCaseResponse> handle(SignInUseCaseRequest request) async {
    var message = 'An unexpected error happened.';
    try {
      final user = await _authService.signInWithEmail(request.email, request.password);
      if (user != null) {
        return SignInUseCaseResponse(user);
      }
    } catch (error) {
      print(error);
      message = error.toString();
    }
    return SignInUseCaseResponse(null, message: message);
  }

}
