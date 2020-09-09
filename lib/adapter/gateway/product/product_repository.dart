import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/repositories/product_repository.dart' as i_product_repository;

class ProductRepository implements i_product_repository.ProductRepository {

  DocumentSnapshot _lastVisible;
  String _lastSearchQuery;
  String _lastOrderBy;
  bool _lastDescending;

  CollectionReference getCollection(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).collection("products");
  }

  Future<List<Product>> list(String userId, {String searchQuery, String orderBy = 'createdAt', bool descending = false, int limit = 0}) async {
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
      query = query.startAfter([_lastVisible]);
    }

    final querySnapshot = await query.get();

    _lastOrderBy = orderBy;
    _lastDescending = descending;
    _lastSearchQuery = searchQuery;

    if (querySnapshot.docs.length == 0) return List<Product>();
    _lastVisible = querySnapshot.docs[querySnapshot.docs.length - 1];
    return querySnapshot.docs.map((snapshot) => Product.fromMap(snapshot.data())).toList();
  }

  Future<Product> get(String userId, String productId) async {
    final snapshot = await getCollection(userId).doc(productId).get();
    if (!snapshot.exists) return null;
    return Product.fromMap(snapshot.data());
  }

  Future<Product> add(String userId, Product product) {
    return Future(() async {
      final doc = getCollection(userId).doc(product.id);
      StreamSubscription streamSubscription;
      streamSubscription = doc.snapshots().listen((event) {
        streamSubscription.cancel();
        final product = Product.fromMap(event.data());
        return product;
      });
      var data = product.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      print(product.websiteUrl);
      await doc.set(data);
    }).timeout(Duration(seconds: 30), onTimeout: () {
      return null;
    });
  }

  Future<Product> update(String userId, Product product) async {
    return Future(() async {
      final doc = getCollection(userId).doc();
      StreamSubscription streamSubscription;
      streamSubscription = doc.snapshots().listen((event) {
        streamSubscription.cancel();
        return Product.fromMap(event.data());
      });
      var data = product.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await doc.update(data);
    }).timeout(Duration(seconds: 30), onTimeout: () {
      return null;
    });
  }

  Future<Product> delete(String userId, Product product) async {
    await getCollection(userId).doc().delete();
    return product;
  }


  String nextIdentity() {
    var uuid = Uuid();
    return uuid.v4();
  }

}
