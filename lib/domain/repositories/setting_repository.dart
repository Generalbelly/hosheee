import 'dart:async';
import 'package:hosheee/domain/models/setting.dart';

abstract class SettingRepository {

  Stream<Setting> get(String userId);

  Future<void> add(String userId, Setting setting);

  Future<void> update(String userId, Setting setting);

  Future<void> delete(String userId, Setting setting);

  String nextIdentity();

}
