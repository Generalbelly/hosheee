import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/utils/helpers.dart';

class SignUpUseCaseRequest {
  String email;
  String password;

  SignUpUseCaseRequest(this.email, this.password);

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }
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
    try {
      final user = await _authService.signUpWithEmail(request.email, request.password);
      return SignUpUseCaseResponse(user);
    } catch (e) {
      final message = e.toString();
      logger().error(message, {
        'request': request.toMap(),
      });
      return SignUpUseCaseResponse(null, message: message);
    }
  }

}
