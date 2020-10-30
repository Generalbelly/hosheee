import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/user_repository.dart' as i_user_repository;

class UserRepository implements i_user_repository.UserRepository {

  final CollectionReference collection = FirebaseFirestore.instance.collection('users');

  Future<User> get(String uid) async {
    final snapshot = await collection.doc(uid).get();
    if (!snapshot.exists) return null;
    return User.fromMap(snapshot.data());
  }

  Future<void> add(User user) async {
    await collection.add(user.toMap());
  }

  Future<void> update(User user) async {
    await collection.doc(user.id).update(user.toMap());
  }

  Future<void> delete(User user) async {
    await collection.doc(user.id).delete();
  }

}
