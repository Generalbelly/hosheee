import 'package:hosheee/domain/models/user.dart';

abstract class UserRepository {

  Future<User> get(String uid);

  Future<dynamic> add(User user);

  Future<dynamic> update(User user);

  Future<dynamic> delete(User user);

}
