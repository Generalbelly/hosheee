import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:hosheee/adapter/gateway/product/firestore.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/repositories/product_repository.dart' as i_product_repository;

class ProductRepository implements i_product_repository.ProductRepository {

  ListProductsQueryManager _listQueryManager;
  ListProductsQueryManager get listQueryManager => _listQueryManager;
  set listQueryManager(ListProductsQueryManager value) {
    if (_listQueryManager != null) {
      _listQueryManager.detachListeners();
    }
    _listQueryManager = value;
  }

  void list(String userId, Function(List<Product>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0}) {
    final pqc = ListProductsQueryManager(userId, searchQuery, orderBy, descending, startIndex, limit);
    if (listQueryManager != null) {
      if (pqc.isEqualTo(listQueryManager)) {
        callback(listQueryManager.getRange(startIndex, limit));
        return;
      } else if (pqc.isSubsequentTo(listQueryManager)) {
        listQueryManager.startIndex = pqc.startIndex;
      } else {
        listQueryManager = pqc;
      }
    } else {
      listQueryManager = pqc;
    }
    final query = listQueryManager.query();

    final listener = query.snapshots().listen(listQueryManager.createSnapshotHandler(callback));
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
