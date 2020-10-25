import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/adapter/gateway/collection_product/firestore.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/repositories/collection_product_repository.dart' as i_collection_product_repository;

class CollectionProductRepository implements i_collection_product_repository.CollectionProductRepository {

  ListByCollectionProductsByCollectionIdQueryManager _listCollectionProductsByCollectionIdQueryManager;
  ListByCollectionProductsByCollectionIdQueryManager get listCollectionProductsByCollectionIdQueryManager => _listCollectionProductsByCollectionIdQueryManager;
  set listCollectionProductsByCollectionIdQueryManager(ListByCollectionProductsByCollectionIdQueryManager value) {
    if (_listCollectionProductsByCollectionIdQueryManager != null) {
      _listCollectionProductsByCollectionIdQueryManager.detachListeners();
    }
    _listCollectionProductsByCollectionIdQueryManager = value;
  }

  ListByCollectionProductsByProductIdQueryManager _listCollectionProductsByProductIdQueryManager;
  ListByCollectionProductsByProductIdQueryManager get listCollectionProductsByProductIdQueryManager => _listCollectionProductsByProductIdQueryManager;
  set listCollectionProductsByProductIdQueryManager(ListByCollectionProductsByProductIdQueryManager value) {
    if (_listCollectionProductsByProductIdQueryManager != null) {
      _listCollectionProductsByProductIdQueryManager.detachListeners();
    }
    _listCollectionProductsByProductIdQueryManager = value;
  }

  void listByCollectionId(String userId, String collectionId, Function(List<CollectionProduct>) callback, {String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0}) {
    final pqc = ListByCollectionProductsByCollectionIdQueryManager(userId, collectionId, orderBy, descending, startIndex, limit);
    if (listCollectionProductsByCollectionIdQueryManager != null) {
      if (pqc.isEqualTo(listCollectionProductsByCollectionIdQueryManager)) {
        callback(listCollectionProductsByCollectionIdQueryManager.getRange(startIndex, limit));
        return;
      } else if (pqc.isSubsequentTo(listCollectionProductsByCollectionIdQueryManager)) {
        listCollectionProductsByCollectionIdQueryManager.startIndex = pqc.startIndex;
      } else {
        listCollectionProductsByCollectionIdQueryManager = pqc;
      }
    } else {
      listCollectionProductsByCollectionIdQueryManager = pqc;
    }
    final query = listCollectionProductsByCollectionIdQueryManager.query();

    final listener = query.snapshots().listen(listCollectionProductsByCollectionIdQueryManager.createSnapshotHandler(callback));
    listCollectionProductsByCollectionIdQueryManager.attachListener(listener);
  }

  void listByProductId(String userId, String productId, Function(List<CollectionProduct>) callback, {String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0}) {
    final pqc = ListByCollectionProductsByProductIdQueryManager(userId, productId, orderBy, descending, startIndex, limit);
    if (listCollectionProductsByProductIdQueryManager != null) {
      if (pqc.isEqualTo(listCollectionProductsByProductIdQueryManager)) {
        callback(listCollectionProductsByProductIdQueryManager.getRange(startIndex, limit));
        return;
      }
      if (pqc.isSubsequentTo(listCollectionProductsByProductIdQueryManager)) {
        listCollectionProductsByProductIdQueryManager.startIndex = pqc.startIndex;
      }
    } else if (listCollectionProductsByProductIdQueryManager == null || !pqc.isSubsequentTo(listCollectionProductsByProductIdQueryManager)) {
      listCollectionProductsByProductIdQueryManager = pqc;
    }
    final query = listCollectionProductsByProductIdQueryManager.query();

    final listener = query.snapshots().listen(listCollectionProductsByProductIdQueryManager.createSnapshotHandler(callback));
    listCollectionProductsByProductIdQueryManager.attachListener(listener);
  }

  Future<void> add(String userId, CollectionProduct collectionProduct) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection('collection_products').doc(collectionProduct.id);
    var data = collectionProduct.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.set(data);
  }

  Future<void> batchUpsert(String userId, List<CollectionProduct> collectionProducts) async {
    final batch = FirebaseFirestore.instance.batch();
    collectionProducts.forEach((collectionProduct) {
      final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection('collection_products').doc(collectionProduct.id);
      var data = collectionProduct.toMap();
      if (data['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      } else {
        data.removeWhere((key, value) => key == "createdAt");
      }
      data['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(doc, data);
    });
    await batch.commit();
  }

  Future<void> batchDelete(String userId, List<CollectionProduct> collectionProducts) async {
    final batch = FirebaseFirestore.instance.batch();
    collectionProducts.forEach((collectionProduct) {
      final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection('collection_products').doc(collectionProduct.id);
      batch.delete(doc);
    });
    await batch.commit();
  }

  String nextIdentity(String collectionId, String productId) {
    return collectionId + '_' + productId;
  }

}
