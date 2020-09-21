import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/repositories/product_repository.dart' as i_product_repository;

class ProductRepository implements i_product_repository.ProductRepository {

  List<List<Product>> _allProducts;
  DocumentSnapshot _lastVisible;
  String _lastSearchQuery;
  String _lastOrderBy;
  bool _lastDescending;
  List<StreamSubscription> _listListeners = [];

  CollectionReference getCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection("products");
  }

  void list(String userId, Function(List<Product>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0}) {
    if (_lastSearchQuery != searchQuery || _lastOrderBy != orderBy || _lastDescending != descending) {
      _allProducts = [];
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

    final handler = (productsIndex, limit, descending) => (QuerySnapshot snapshot) {
      if (snapshot.docChanges.length == 0) {
        callback([]);
        return;
      }
      if (_lastVisible == null) {
        _lastVisible = snapshot.docChanges[snapshot.docChanges.length - 1].doc;
      }
      var products = List<Product>();
      if (_allProducts.length > productsIndex) {
        products = _allProducts[productsIndex];
      }
      snapshot.docChanges.forEach((docChange) {
        final incomingProduct = Product.fromMap(docChange.doc.data());
        print("productId:${incomingProduct.id}");
        print("createdAt:${incomingProduct.createdAt}");
        print("updatedAt:${incomingProduct.updatedAt}");
        print("oldIndex:${docChange.oldIndex}");
        print("newIndex:${docChange.newIndex}");
        print("newIndex:${docChange.type}");
        if (docChange.type == DocumentChangeType.added) {
          products.insert(docChange.newIndex, incomingProduct);
        }
        if (docChange.type == DocumentChangeType.modified) {
          final productIndex = products.indexWhere((product) => product.id == incomingProduct.id);
          products[productIndex] = incomingProduct;
        }
        if (docChange.type == DocumentChangeType.removed) {
          products.removeWhere((product) => product.id == incomingProduct.id);
        }
      });
      if (_allProducts.length > productsIndex) {
        _allProducts[productsIndex] = products;
      } else {
        _allProducts.add(products);
      }
      callback(_allProducts.expand((ps) => ps).toList());
      return;
    };
    final listener = query.snapshots().listen(handler(_allProducts.length, limit, descending));
    _listListeners.add(listener);
  }

  Future<Product> get(String userId, String productId) async {
    final snapshot = await getCollection(userId).doc(productId).get();
    if (!snapshot.exists) return null;
    return Product.fromMap(snapshot.data());
  }

  Future<void> add(String userId, Product product) async {
    final doc = getCollection(userId).doc(product.id);
    var data = product.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.set(data);
  }

  Future<void> update(String userId, Product product) async {
    final doc = getCollection(userId).doc(product.id);
    var data = product.toMap();
    data.removeWhere((key, value) => key == "createdAt");
    data['updatedAt'] = FieldValue.serverTimestamp();
    await doc.update(data);
  }

  Future<void> delete(String userId, Product product) async {
    await getCollection(userId).doc(product.id).delete();
  }


  String nextIdentity() {
    var uuid = Uuid();
    return uuid.v4();
  }

}
