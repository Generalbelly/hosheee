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
  void upsertResult(int resultIndex, List<Model> result);
  List<Model> retrieveResult(int resultIndex);
  List<Model> getCombinedResult();
  Function(QuerySnapshot snapshot) getSnapshotHandler(Function cb);
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

  void upsertResult(int resultIndex, List<Model> result) {
    if (accumulatedResult.length > resultIndex) {
      accumulatedResult[resultIndex] = result;
    } else {
      accumulatedResult.add(result);
    }
  }

  List<Product> retrieveResult(int resultIndex) {
    var products = List<Product>();
    if (accumulatedResult.length > resultIndex) {
      products = accumulatedResult[resultIndex];
    }
    return products;
  }

  List<Product> getCombinedResult() {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  Function(QuerySnapshot snapshot) getSnapshotHandler(Function cb) {
    return (int resultIndex) {
      return (QuerySnapshot snapshot) {
        if (snapshot.docChanges.length == 0) {
          return;
        }
        if (lastVisible == null) {
          lastVisible = snapshot.docChanges[snapshot.docChanges.length - 1].doc;
        }
        var products = retrieveResult(resultIndex);
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
        upsertResult(resultIndex, products);
        cb();
      };
    }(accumulatedResult.length);
  }

  Query getListQuery(String userId) {
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

  Query getListByCollectionQuery(String userId, String collectionId) {
    var query = FirebaseFirestore.instance.collection('users').doc(userId).collection("products")
      .where('collectionId', isEqualTo: collectionId)
      .orderBy(orderBy, descending: descending);
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
