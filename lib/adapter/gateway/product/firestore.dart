import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/adapter/gateway/firestore.dart';
import 'package:hosheee/domain/models/product.dart';

class ListProductsQueryManager extends QueryManager {
  List<List<Product>> accumulatedResult = [];
  String userId;
  String searchQuery;
  String orderBy;
  bool descending;
  int startIndex;
  int limit;

  ListProductsQueryManager(this.userId, this.searchQuery, this.orderBy, this.descending, this.startIndex, this.limit);

  bool isSubsequentTo(QueryManager qm) {
    if (qm is ListProductsQueryManager) {
      return (
        userId == qm.userId &&
        searchQuery == qm.searchQuery &&
        orderBy == qm.orderBy &&
        descending == qm.descending &&
        startIndex > qm.startIndex &&
        limit == qm.limit
      );
    }
    return false;
  }

  bool isEqualTo(QueryManager qm) {
    if (qm is ListProductsQueryManager) {
      return (
        userId == qm.userId &&
        searchQuery == qm.searchQuery &&
        orderBy == qm.orderBy &&
        descending == qm.descending &&
        startIndex == qm.startIndex &&
        limit == qm.limit
      );
    }
    return false;
  }

  void _upsertResult(int resultIndex, List<Product> result) {
    if (accumulatedResult.length > resultIndex) {
      accumulatedResult[resultIndex] = result;
    } else {
      accumulatedResult.add(result);
    }
  }

  List<Product> _retrieveResult(int resultIndex) {
    var products = List<Product>();
    if (accumulatedResult.length > resultIndex) {
      products = accumulatedResult[resultIndex];
    }
    return products;
  }

  List<Product> all() {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  List<Product> getRange(int startIndex, int limit) {
    final index = startIndex == 0 ? 0 : startIndex ~/ limit;
    return accumulatedResult[index];
  }

  Function(QuerySnapshot snapshot) createSnapshotHandler(Function(List<Product>) cb) {
    return (int resultIndex) {
      return (QuerySnapshot snapshot) {
        if (snapshot.docChanges.length == 0) {
          _upsertResult(resultIndex, List<Product>());
          cb(accumulatedResult[resultIndex]);
          return;
        }
        if (lastVisible == null) {
          lastVisible = snapshot.docChanges[snapshot.docChanges.length - 1].doc;
        }
        var products = _retrieveResult(resultIndex);
        snapshot.docChanges.forEach((docChange) {
          final incomingProduct = Product.fromMap(docChange.doc.data());
          // print("productId:${incomingProduct.id}");
          // print("createdAt:${incomingProduct.createdAt}");
          // print("updatedAt:${incomingProduct.updatedAt}");
          // print("oldIndex:${docChange.oldIndex}");
          // print("newIndex:${docChange.newIndex}");
          // print("newIndex:${docChange.type}");
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
        _upsertResult(resultIndex, products);
        cb(accumulatedResult[resultIndex]);
      };
    }(accumulatedResult.length);
  }

  Query query() {
    var query;
    if (searchQuery != null) {
      query = FirebaseFirestore.instance.collection('users').doc(userId).collection("products")
        .orderBy(orderBy, descending: descending)
        .startAt([searchQuery])
        .endAt(['$searchQuery\uf8ff']);
    } else {
      query = FirebaseFirestore.instance.collection('users').doc(userId).collection("products")
        .orderBy(orderBy, descending: descending);
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
