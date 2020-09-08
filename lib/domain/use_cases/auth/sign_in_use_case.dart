import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/utils/helpers.dart';

class SignInUseCaseRequest {
  String email;
  String password;

  SignInUseCaseRequest(this.email, this.password);

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }
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
    try {
      final user = await _authService.signInWithEmail(request.email, request.password);
      return SignInUseCaseResponse(user);
    } catch (e) {
      final message = e.toString();
      logger().error(message, {
        'request': request.toMap(),
      });
      return SignInUseCaseResponse(null, message: message);
    }
  }

}
