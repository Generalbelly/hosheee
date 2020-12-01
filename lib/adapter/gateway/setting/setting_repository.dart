import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:hosheee/domain/models/setting.dart';
import 'package:hosheee/domain/repositories/setting_repository.dart' as i_setting_repository;

class SettingRepository implements i_setting_repository.SettingRepository {

  Stream<Setting> get(String userId) async* {
    final stream = FirebaseFirestore.instance.collection('users')
        .doc(userId)
        .collection("settings")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
    await for (var snapshot in stream) {
      if (snapshot.metadata.hasPendingWrites) {
        continue;
      }
      if (snapshot.docs.length == 0) {
        yield null;
      } else {
        yield Setting.fromMap(snapshot.docs[0].data());
      }
    }
  }

  Future<void> add(String userId, Setting setting) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection("settings").doc(setting.id);
    var data = setting.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.set(data);
  }

  Future<void> update(String userId, Setting setting) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection("settings").doc(setting.id);
    var data = setting.toMap();
    data.removeWhere((key, value) => key == "createdAt");
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.update(data);
  }

  Future<void> delete(String userId, Setting setting) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection("settings").doc(setting.id).delete();
  }

  String nextIdentity() {
    var uuid = Uuid();
    return uuid.v4();
  }

}
