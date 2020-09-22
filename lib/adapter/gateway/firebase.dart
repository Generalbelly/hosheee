import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wish_list/domain/models/model.dart';
import 'dart:async';
import 'package:wish_list/domain/models/product.dart';

abstract class QueryManager {
  String searchQuery;
  String orderBy;
  bool descending;
  int limit;

  bool isEqualTo(QueryManager qm);
  void detachListeners();
  void attachListener(StreamSubscription listener);
  void upsertResult(int index, List<Model> result);
  List<Model> retrieveResult(int index);
  List<Model> getCombinedResult();
  Query getQuery(String userId);
}

class ProductQueryConfig implements QueryManager {
  List<List<Product>> accumulatedResult = [];
  DocumentSnapshot lastVisible;
  String searchQuery;
  String orderBy;
  bool descending;
  int limit;
  List<StreamSubscription> _listeners = [];

  ProductQueryConfig(this.searchQuery, this.orderBy, this.descending, this.limit);

  bool isEqualTo(QueryManager qm) {
    return (searchQuery == qm.searchQuery && orderBy == qm.orderBy && descending == qm.descending && limit == qm.limit);
  }

  void detachListeners() {
    _listeners.forEach((listListener) async { await listListener.cancel(); });
  }

  void attachListener(StreamSubscription listener) {
    _listeners.add(listener);
  }

  void upsertResult(int index, List<Model> result) {
    if (accumulatedResult.length > index) {
      accumulatedResult[index] = result;
    } else {
      accumulatedResult.add(result);
    }
  }

  List<Product> retrieveResult(int index) {
    var products = List<Product>();
    if (accumulatedResult.length > index) {
      products = accumulatedResult[index];
    }
    return products;
  }

  List<Product> getCombinedResult() {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  Query getQuery(String userId) {
    var query;
    if (searchQuery != null) {
      query = FirebaseFirestore.instance.collection('users').doc(userId).collection("products")
          .orderBy(orderBy, descending: descending)
          .startAt([searchQuery])
          .endAt(['$searchQuery\uf8ff']);
    } else {
      query = FirebaseFirestore.instance.collection('users').doc(userId).collection("products").orderBy(orderBy, descending: descending);
    }
    if (limit > 0) {
      query = query.limit(limit);
    }
    if (lastVisible != null) {
      query = query.startAfter([lastVisible.data()[orderBy]]);
    }

    lastVisible = null;

    return query;
  }

}
