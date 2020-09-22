import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:wish_list/adapter/gateway/firebase.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/repositories/product_repository.dart' as i_product_repository;

class ProductRepository implements i_product_repository.ProductRepository {

  ProductQueryConfig _listQueryConfig = ProductQueryConfig(null, 'createdAt', true, 0);

  ProductQueryConfig get listQueryConfig => _listQueryConfig;
  set listQueryConfig(ProductQueryConfig value) {
    _listQueryConfig.detachListeners();
    _listQueryConfig = value;
  }

  CollectionReference getCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection("products");
  }

  void listByCollectionId(String userId, String collectionId, Function(List<Product>) callback, {String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    final pqc = ProductQueryConfig(null, orderBy, descending, limit);
    if (!listQueryConfig.isEqualTo(pqc)) {
      listQueryConfig = pqc;
    }
    final query = listQueryConfig.getListByCollectionQuery(userId, collectionId);

    final handler = (productsIndex) => (QuerySnapshot snapshot) {
      listQueryConfig.handleSnapshot(productsIndex, snapshot);
      callback(listQueryConfig.getCombinedResult());
    };
    final listener = query.snapshots().listen(handler(listQueryConfig.accumulatedResult.length));
    listQueryConfig.attachListener(listener);
  }

  void list(String userId, Function(List<Product>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    final pqc = ProductQueryConfig(searchQuery, orderBy, descending, limit);
    if (!listQueryConfig.isEqualTo(pqc)) {
      listQueryConfig = pqc;
    }
    final query = listQueryConfig.getListQuery(userId);

    final handler = (productsIndex) => (QuerySnapshot snapshot) {
      listQueryConfig.handleSnapshot(productsIndex, snapshot);
      callback(listQueryConfig.getCombinedResult());
    };
    final listener = query.snapshots().listen(handler(listQueryConfig.accumulatedResult.length));
    listQueryConfig.attachListener(listener);
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
