import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/user_repository.dart' as i_user_repository;

class UserRepository implements i_user_repository.UserRepository {

  final CollectionReference collection = Firestore.instance.collection('users');

  Future<User> get(String uid) async {
    final snapshot = await collection.document(uid).get();
    if (!snapshot.exists) return null;
    return User.fromMap(snapshot.data());
  }

  Future<void> add(User user) async {
    await collection.add(user.toMap());
  }

  Future<void> update(User user) async {
    await collection.document(user.id).updateData(user.toMap());
  }

  Future<void> delete(User user) async {
    await collection.document(user.id).delete();
  }

}
