import 'dart:async';
import 'package:hosheee/domain/models/user.dart';

abstract class Auth {
  Future<User> signUpWithEmail(String email, String password);

  Future<User> signInWithEmail(String email, String password);

  Future<void> sendEmailVerification(String email, String password);

  Future<void> resetPassword(String code, String password);

  Future<void> signOut();

  Future<User> user();

  StreamSubscription onAuthStateChanged(Function(User) callback);
}
