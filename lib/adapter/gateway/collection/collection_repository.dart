import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/adapter/gateway/collection/firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/repositories/collection_repository.dart' as i_collection_repository;

class CollectionRepository implements i_collection_repository.CollectionRepository {

  ListCollectionsQueryManager _listQueryManager;
  ListCollectionsQueryManager get listQueryManager => _listQueryManager;
  set listQueryManager(ListCollectionsQueryManager value) {
    if (_listQueryManager != null) {
      _listQueryManager.detachListeners();
    }
    _listQueryManager = value;
  }

  CollectionReference getCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection("collections");
  }

  void list(String userId, Function(List<Collection>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    final pqc = ListCollectionsQueryManager(userId, searchQuery, orderBy, descending, limit);
    if (listQueryManager != null && listQueryManager.isEqualTo(pqc)) {
      callback(listQueryManager.getCombinedResult());
      return;
    }
    if (listQueryManager == null || !listQueryManager.isSubsequentTo(pqc)) {
      listQueryManager = pqc;
    }
    final query = listQueryManager.query();

    final listener = query.snapshots().listen(listQueryManager.getSnapshotHandler(() {
      callback(listQueryManager.getCombinedResult());
    }));
    listQueryManager.attachListener(listener);
  }

  Future<Collection> get(String userId, String collectionId) async {
    final snapshot = await getCollection(userId).doc(collectionId).get();
    if (!snapshot.exists) return null;
    return Collection.fromMap(snapshot.data());
  }

  Future<void> add(String userId, Collection collection) async {
    final doc = getCollection(userId).doc(collection.id);
    var data = collection.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.set(data);
  }

  Future<void> update(String userId, Collection collection) async {
    final doc = getCollection(userId).doc(collection.id);
    var data = collection.toMap();
    data.removeWhere((key, value) => key == "createdAt");
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.update(data);
  }

  Future<void> delete(String userId, Collection collection) async {
    await getCollection(userId).doc(collection.id).delete();
  }


  String nextIdentity() {
    var uuid = Uuid();
    return uuid.v4();
  }

}
