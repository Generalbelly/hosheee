import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart' as i_collection_repository;

class CollectionRepository implements i_collection_repository.CollectionRepository {

  List<List<Collection>> _allCollections;
  DocumentSnapshot _lastVisible;
  String _lastSearchQuery;
  String _lastOrderBy;
  bool _lastDescending;
  List<StreamSubscription> _listListeners = [];

  CollectionReference getCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection("collections");
  }

  void list(String userId, Function(List<Collection>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    if (_lastSearchQuery != searchQuery || _lastOrderBy != orderBy || _lastDescending != descending) {
      _allCollections = [];
      _lastVisible = null;
      _listListeners.forEach((listListener) async { await listListener.cancel(); });
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

    _lastOrderBy = orderBy;
    _lastDescending = descending;
    _lastSearchQuery = searchQuery;
    _lastVisible = null;

    final handler = (collectionsIndex, limit, descending) => (QuerySnapshot snapshot) {
      if (snapshot.docChanges.length == 0) {
        callback([]);
        return;
      }
      if (_lastVisible == null) {
        _lastVisible = snapshot.docChanges[snapshot.docChanges.length - 1].doc;
      }
      var collections = List<Collection>();
      if (_allCollections.length > collectionsIndex) {
        collections = _allCollections[collectionsIndex];
      }
      snapshot.docChanges.forEach((docChange) {
        final incomingCollection = Collection.fromMap(docChange.doc.data());
        print("collectionId:${incomingCollection.id}");
        print("createdAt:${incomingCollection.createdAt}");
        print("updatedAt:${incomingCollection.updatedAt}");
        print("oldIndex:${docChange.oldIndex}");
        print("newIndex:${docChange.newIndex}");
        print("newIndex:${docChange.type}");
        if (docChange.type == DocumentChangeType.added) {
          collections.insert(docChange.newIndex, incomingCollection);
        }
        if (docChange.type == DocumentChangeType.modified) {
          final collectionIndex = collections.indexWhere((collection) => collection.id == incomingCollection.id);
          collections[collectionIndex] = incomingCollection;
        }
        if (docChange.type == DocumentChangeType.removed) {
          collections.removeWhere((collection) => collection.id == incomingCollection.id);
        }
      });
      if (_allCollections.length > collectionsIndex) {
        _allCollections[collectionsIndex] = collections;
      } else {
        _allCollections.add(collections);
      }
      callback(_allCollections.expand((ps) => ps).toList());
      return;
    };
    final listener = query.snapshots().listen(handler(_allCollections.length, limit, descending));
    _listListeners.add(listener);
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
