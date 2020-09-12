import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart' as i_collection_repository;

class CollectionRepository implements i_collection_repository.CollectionRepository {

  DocumentSnapshot _lastVisible;
  String _lastSearchQuery;
  String _lastOrderBy;
  bool _lastDescending;

  CollectionReference getCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection("collections");
  }

  Future<List<Collection>> list(String userId, {String searchQuery, String orderBy = 'createdAt', bool descending = false, int limit = 0}) async {
    if (_lastSearchQuery != searchQuery || _lastOrderBy != orderBy || _lastDescending != descending) {
      _lastVisible = null;
    }
    Query query;
    if (searchQuery != null) {
      query = getCollection(userId)
          .orderBy(orderBy, descending: descending)
          .startAt([searchQuery])
          .endAt(['$searchQuery\uf8ff']);
    } else {
      query = getCollection(userId).orderBy(orderBy, descending: descending);
    }
    if (limit > 0) {
      query = query.limit(limit);
    }
    if (_lastVisible != null) {
      query = query.startAfter([_lastVisible.data()[orderBy]]);
    }

    final querySnapshot = await query.get();

    _lastOrderBy = orderBy;
    _lastDescending = descending;
    _lastSearchQuery = searchQuery;

    if (querySnapshot.docs.length == 0) return List<Collection>();
    _lastVisible = querySnapshot.docs[querySnapshot.docs.length - 1];
    return querySnapshot.docs.map((snapshot) => Collection.fromMap(snapshot.data())).toList();
  }

  Future<Collection> get(String userId, String collectionId) async {
    final snapshot = await getCollection(userId).doc(collectionId).get();
    if (!snapshot.exists) return null;
    return Collection.fromMap(snapshot.data());
  }

  Future<Collection> add(String userId, Collection collection) {
    return Future(() async {
      final doc = getCollection(userId).doc(collection.id);
      StreamSubscription streamSubscription;
      streamSubscription = doc.snapshots().listen((event) {
        streamSubscription.cancel();
        final collection = Collection.fromMap(event.data());
        return collection;
      });
      var data = collection.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await doc.set(data);
    }).timeout(Duration(seconds: 30), onTimeout: () {
      return null;
    });
  }

  Future<Collection> update(String userId, Collection collection) async {
    return Future(() async {
      final doc = getCollection(userId).doc();
      StreamSubscription streamSubscription;
      streamSubscription = doc.snapshots().listen((event) {
        streamSubscription.cancel();
        return Collection.fromMap(event.data());
      });
      var data = collection.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await doc.update(data);
    }).timeout(Duration(seconds: 30), onTimeout: () {
      return null;
    });
  }

  Future<Collection> delete(String userId, Collection collection) async {
    await getCollection(userId).doc().delete();
    return collection;
  }

  String nextIdentity() {
    var uuid = Uuid();
    return uuid.v4();
  }

}
