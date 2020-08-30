class AuthException implements Exception {

  String _message;

  AuthException([String message = 'AuthException']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }

}
