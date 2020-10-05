import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:hosheee/domain/models/auth.dart' as i_auth;
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/models/exceptions/auth_exception.dart' as auth_exception;

class Auth implements i_auth.Auth {

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  Future<User> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        return _createUserFrom(credential.user);
      }
      return null;
    } catch (error) {
      throw _createAuthServiceException(error);
    }
  }

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        return _createUserFrom(credential.user);
      }
      return null;
    } catch (error) {
      throw _createAuthServiceException(error);
    }
  }

  auth_exception.AuthException _createAuthServiceException(Exception error) {
    var message = error.toString();
    if (error is PlatformException) {
      switch (error.code) {
        case 'ERROR_INVALID_EMAIL':
          message = 'The email is not valid.';
          break;
        case 'ERROR_WEAK_PASSWORD':
          message = 'The password is not strong enough. It should be at least 6 characters.';
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          message = 'The email is already registered';
          break;
        case 'ERROR_WRONG_PASSWORD':
          message = "The password is incorrect.";
          break;
        case 'ERROR_USER_NOT_FOUND':
          message = 'We could not find an account with the email.';
          break;
        case 'ERROR_USER_DISABLED':
          message = 'User with the email has been disabled.';
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          message = 'Too many requests. Try again later.';
          break;
      }
    }
    return auth_exception.AuthException(message);
  }

  User _createUserFrom(firebase_auth.User firebaseUser) {
    return User(firebaseUser.uid, firebaseUser.email);
  }

  Future<void> sendEmailVerification(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<void> resetPassword(String code, String password) async {
    await _auth.confirmPasswordReset(code: code, newPassword: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User> user() async {
    final firebaseUser = _auth.currentUser;
    return firebaseUser != null ? _createUserFrom(firebaseUser) : null;
  }

  StreamSubscription onAuthStateChanged(Function(User) callback) {
    return _auth.authStateChanges().listen((firebase_auth.User firebaseUser) {
      var user;
      if (firebaseUser != null) {
        user = _createUserFrom(firebaseUser);
      }
      callback(user);
    });
  }

}
