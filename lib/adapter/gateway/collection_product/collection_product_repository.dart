import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/adapter/gateway/collection_product/firestore.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:uuid/uuid.dart';
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

  void listByCollectionId(String userId, String collectionId, Function(List<CollectionProduct>) callback, {String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    final pqc = ListByCollectionProductsByCollectionIdQueryManager(userId, collectionId, orderBy, descending, limit);
    if (listCollectionProductsByCollectionIdQueryManager != null && listCollectionProductsByCollectionIdQueryManager.isEqualTo(pqc)) {
      callback(listCollectionProductsByCollectionIdQueryManager.getCombinedResult());
      return;
    }
    if (listCollectionProductsByCollectionIdQueryManager == null || !listCollectionProductsByCollectionIdQueryManager.isSubsequentTo(pqc)) {
      listCollectionProductsByCollectionIdQueryManager = pqc;
    }
    final query = listCollectionProductsByCollectionIdQueryManager.query();
    final listener = query.snapshots().listen(listCollectionProductsByCollectionIdQueryManager.getSnapshotHandler(() {
      callback(listCollectionProductsByCollectionIdQueryManager.getCombinedResult());
    }));
    listCollectionProductsByCollectionIdQueryManager.attachListener(listener);
  }

  Future<void> add(String userId, CollectionProduct collectionProduct) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection('collection_products').doc(collectionProduct.id);
    var data = collectionProduct.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.set(data);
  }

  Future<void> batchAdd(String userId, List<CollectionProduct> collectionProducts) async {
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

  String nextIdentity() {
    var uuid = Uuid();
    return uuid.v4();
  }

}
