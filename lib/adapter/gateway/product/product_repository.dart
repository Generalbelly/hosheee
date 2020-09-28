import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:wish_list/adapter/gateway/product/firebase.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/repositories/product_repository.dart' as i_product_repository;

class ProductRepository implements i_product_repository.ProductRepository {

  ListProductsQueryManager _listQueryManager;
  ListProductsByCollectionIdQueryManager _listByCollectionIdQueryManager;

  ListProductsQueryManager get listQueryManager => _listQueryManager;
  set listQueryManager(ListProductsQueryManager value) {
    if (_listQueryManager != null) {
      _listQueryManager.detachListeners();
    }
    _listQueryManager = value;
  }

  ListProductsByCollectionIdQueryManager get listByCollectionIdQueryManager => _listByCollectionIdQueryManager;
  set listByCollectionIdQueryManager(ListProductsByCollectionIdQueryManager value) {
    if (_listByCollectionIdQueryManager != null) {
      _listByCollectionIdQueryManager.detachListeners();
    }
    _listByCollectionIdQueryManager = value;
  }

  void listByCollectionId(String userId, String collectionId, Function(List<Product>) callback, {String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    final pqc = ListProductsByCollectionIdQueryManager(userId, collectionId, orderBy, descending, limit);
    print(userId);
    print(collectionId);
    print(descending);
    print(limit);
    if (listByCollectionIdQueryManager == null || !listByCollectionIdQueryManager.isEqualTo(pqc)) {
      print('first time or not equal');
      listByCollectionIdQueryManager = pqc;
    }
    final query = listByCollectionIdQueryManager.query();

    final listener = query.snapshots().listen(listByCollectionIdQueryManager.getSnapshotHandler(() {
      callback(listByCollectionIdQueryManager.getCombinedResult());
    }));
    print(listByCollectionIdQueryManager.accumulatedResult.length);
    listByCollectionIdQueryManager.attachListener(listener);
  }

  void list(String userId, Function(List<Product>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    final pqc = ListProductsQueryManager(userId, searchQuery, orderBy, descending, limit);
    if (listQueryManager == null || !listQueryManager.isEqualTo(pqc)) {
      listQueryManager = pqc;
    }
    final query = listQueryManager.query();

    final listener = query.snapshots().listen(listQueryManager.getSnapshotHandler(() {
      callback(listQueryManager.getCombinedResult());
    }));
    listQueryManager.attachListener(listener);
  }

  Future<Product> get(String userId, String productId) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection("products").doc(productId).get();
    if (!snapshot.exists) return null;
    return Product.fromMap(snapshot.data());
  }

  Future<void> add(String userId, Product product) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection("products").doc(product.id);
    var data = product.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.set(data);
  }

  Future<void> update(String userId, Product product) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(userId).collection("products").doc(product.id);
    var data = product.toMap();
    data.removeWhere((key, value) => key == "createdAt");
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.update(data);
  }

  Future<void> delete(String userId, Product product) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection("products").doc(product.id).delete();
  }


  String nextIdentity() {
    var uuid = Uuid();
    return uuid.v4();
  }

}
