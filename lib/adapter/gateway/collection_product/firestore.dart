import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/adapter/gateway/firestore.dart';
import 'package:hosheee/domain/models/collection_product.dart';

class ListByCollectionProductsByCollectionIdQueryManager extends QueryManager {

  List<List<CollectionProduct>> accumulatedResult = [];
  String userId;
  String collectionId;
  String orderBy;
  bool descending;
  int startIndex;
  int limit;

  ListByCollectionProductsByCollectionIdQueryManager(this.userId, this.collectionId, this.orderBy, this.descending, this.startIndex, this.limit);

  bool isSubsequentTo(QueryManager qm) {
    if (qm is ListByCollectionProductsByCollectionIdQueryManager) {
      return (
        userId == qm.userId &&
        collectionId == qm.collectionId &&
        orderBy == qm.orderBy &&
        descending == qm.descending &&
        startIndex > qm.startIndex &&
        limit == qm.limit
      );
    }
    return false;
  }

  bool isEqualTo(QueryManager qm) {
    if (qm is ListByCollectionProductsByCollectionIdQueryManager) {
      return (
        userId == qm.userId &&
        collectionId == qm.collectionId &&
        orderBy == qm.orderBy &&
        descending == qm.descending &&
        startIndex == qm.startIndex &&
        limit == qm.limit
      );
    }
    return false;
  }

  void _upsertResult(int resultIndex, List<CollectionProduct> result) {
    if (accumulatedResult.length > resultIndex) {
      accumulatedResult[resultIndex] = result;
    } else {
      accumulatedResult.add(result);
    }
  }

  List<CollectionProduct> _retrieveResult(int resultIndex) {
    var collectionProducts = List<CollectionProduct>();
    if (accumulatedResult.length > resultIndex) {
      collectionProducts = accumulatedResult[resultIndex];
    }
    return collectionProducts;
  }

  List<CollectionProduct> all() {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  List<CollectionProduct> getRange(int startIndex, int limit) {
    final index = startIndex == 0 ? 0 : startIndex / limit;
    return accumulatedResult[index];
  }

  Function(QuerySnapshot snapshot) createSnapshotHandler(Function(List<CollectionProduct>) cb) {
    return (int resultIndex) {
      return (QuerySnapshot snapshot) {
        if (snapshot.docChanges.length == 0) {
          cb([]);
          return;
        }
        if (lastVisible == null) {
          lastVisible = snapshot.docChanges[snapshot.docChanges.length - 1].doc;
        }
        var collectionProducts = _retrieveResult(resultIndex);
        snapshot.docChanges.forEach((docChange) {
          final incomingData = CollectionProduct.fromMap(docChange.doc.data());
          print("collectionProductId:${incomingData.id}");
          print("createdAt:${incomingData.createdAt}");
          print("updatedAt:${incomingData.updatedAt}");
          print("oldIndex:${docChange.oldIndex}");
          print("newIndex:${docChange.newIndex}");
          print("newIndex:${docChange.type}");
          if (docChange.type == DocumentChangeType.added) {
            collectionProducts.insert(docChange.newIndex, incomingData);
          }
          if (docChange.type == DocumentChangeType.modified) {
            final collectionProductIndex = collectionProducts.indexWhere((collectionProduct) => collectionProduct.id == incomingData.id);
            collectionProducts[collectionProductIndex] = incomingData;
          }
          if (docChange.type == DocumentChangeType.removed) {
            collectionProducts.removeWhere((collectionProduct) => collectionProduct.id == incomingData.id);
          }
        });
        _upsertResult(resultIndex, collectionProducts);
        cb(accumulatedResult[resultIndex]);
      };
    }(accumulatedResult.length);
  }

  Query query() {
    var query = FirebaseFirestore.instance.collection('users').doc(userId).collection('collection_products')
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


class ListByCollectionProductsByProductIdQueryManager extends QueryManager {

  List<List<CollectionProduct>> accumulatedResult = [];
  String userId;
  String productId;
  String orderBy;
  bool descending;
  int startIndex;
  int limit;

  ListByCollectionProductsByProductIdQueryManager(this.userId, this.productId, this.orderBy, this.descending, this.startIndex, this.limit);

  bool isSubsequentTo(QueryManager qm) {
    if (qm is ListByCollectionProductsByProductIdQueryManager) {
      return (
        userId == qm.userId &&
        productId == qm.productId &&
        orderBy == qm.orderBy &&
        descending == qm.descending &&
        startIndex > qm.startIndex &&
        limit == qm.limit
      );
    }
    return false;
  }

  bool isEqualTo(QueryManager qm) {
    if (qm is ListByCollectionProductsByProductIdQueryManager) {
      return (
        userId == qm.userId &&
        productId == qm.productId &&
        orderBy == qm.orderBy &&
        descending == qm.descending &&
        startIndex == qm.startIndex &&
        limit == qm.limit
      );
    }
    return false;
  }

  void _upsertResult(int resultIndex, List<CollectionProduct> result) {
    if (accumulatedResult.length > resultIndex) {
      accumulatedResult[resultIndex] = result;
    } else {
      accumulatedResult.add(result);
    }
  }

  List<CollectionProduct> _retrieveResult(int resultIndex) {
    var collectionProducts = List<CollectionProduct>();
    if (accumulatedResult.length > resultIndex) {
      collectionProducts = accumulatedResult[resultIndex];
    }
    return collectionProducts;
  }

  List<CollectionProduct> all() {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  List<CollectionProduct> getRange(int startIndex, int limit) {
    final index = startIndex == 0 ? 0 : startIndex / limit;
    return accumulatedResult[index];
  }

  Function(QuerySnapshot snapshot) createSnapshotHandler(Function(List<CollectionProduct>) cb) {
    return (int resultIndex) {
      return (QuerySnapshot snapshot) {
        if (snapshot.docChanges.length == 0) {
          cb([]);
          return;
        }
        if (lastVisible == null) {
          lastVisible = snapshot.docChanges[snapshot.docChanges.length - 1].doc;
        }
        var collectionProducts = _retrieveResult(resultIndex);
        snapshot.docChanges.forEach((docChange) {
          final incomingData = CollectionProduct.fromMap(docChange.doc.data());
          // print("collectionProductId:${incomingProduct.id}");
          // print("createdAt:${incomingProduct.createdAt}");
          // print("updatedAt:${incomingProduct.updatedAt}");
          // print("oldIndex:${docChange.oldIndex}");
          // print("newIndex:${docChange.newIndex}");
          // print("newIndex:${docChange.type}");
          if (docChange.type == DocumentChangeType.added) {
            collectionProducts.insert(docChange.newIndex, incomingData);
          }
          if (docChange.type == DocumentChangeType.modified) {
            final collectionProductIndex = collectionProducts.indexWhere((collectionProduct) => collectionProduct.id == incomingData.id);
            collectionProducts[collectionProductIndex] = incomingData;
          }
          if (docChange.type == DocumentChangeType.removed) {
            collectionProducts.removeWhere((collectionProduct) => collectionProduct.id == incomingData.id);
          }
        });
        _upsertResult(resultIndex, collectionProducts);
        cb(accumulatedResult[resultIndex]);
      };
    }(accumulatedResult.length);
  }

  Query query() {
    var query = FirebaseFirestore.instance.collection('users').doc(userId).collection('collection_products')
        .where('productId', isEqualTo: productId)
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
