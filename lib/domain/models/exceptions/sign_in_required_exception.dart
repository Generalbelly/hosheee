class SignInRequiredException implements Exception {

  String _message;

  SignInRequiredException([String message = 'sign-in required.']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }

}
