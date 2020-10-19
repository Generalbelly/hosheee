import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/adapter/gateway/firestore.dart';
import 'package:hosheee/domain/models/model.dart';
import 'package:hosheee/domain/models/collection.dart';

class ListCollectionsQueryManager extends QueryManager {
  List<List<Collection>> accumulatedResult = [];
  String userId;
  String searchQuery;
  String orderBy;
  bool descending;
  int startIndex;
  int limit;

  ListCollectionsQueryManager(this.userId, this.searchQuery, this.orderBy, this.descending, this.startIndex, this.limit);

  bool isSubsequentTo(QueryManager qm) {
    if (qm is ListCollectionsQueryManager) {
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
    if (qm is ListCollectionsQueryManager) {
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

  void _upsertResult(int resultIndex, List<Model> result) {
    if (accumulatedResult.length > resultIndex) {
      accumulatedResult[resultIndex] = result;
    } else {
      accumulatedResult.add(result);
    }
  }

  List<Collection> _retrieveResult(int resultIndex) {
    var collections = List<Collection>();
    if (accumulatedResult.length > resultIndex) {
      collections = accumulatedResult[resultIndex];
    }
    return collections;
  }

  List<Collection> all() {
    return accumulatedResult.expand((ps) => ps).toList();
  }

  List<Collection> getRange(int startIndex, int limit) {
    final index = startIndex == 0 ? 0 : startIndex / limit;
    final allItems = all();
    if (allItems.length < limit) {
      return allItems.getRange(index, allItems.length);
    }
    return allItems.getRange(index, limit);
  }

  Function(QuerySnapshot snapshot) createSnapshotHandler(Function(List<Collection>) cb) {
    return (int resultIndex) {
      return (QuerySnapshot snapshot) {
        if (snapshot.docChanges.length == 0) {
          cb([]);
          return;
        }
        if (lastVisible == null) {
          lastVisible = snapshot.docChanges[snapshot.docChanges.length - 1].doc;
        }
        var collections = _retrieveResult(resultIndex);
        snapshot.docChanges.forEach((docChange) {
          final incomingCollection = Collection.fromMap(docChange.doc.data());
          // print("collectionId:${incomingCollection.id}");
          // print("createdAt:${incomingCollection.createdAt}");
          // print("updatedAt:${incomingCollection.updatedAt}");
          // print("oldIndex:${docChange.oldIndex}");
          // print("newIndex:${docChange.newIndex}");
          // print("newIndex:${docChange.type}");
          if (docChange.type == DocumentChangeType.added) {
            collections.insert(docChange.newIndex, incomingCollection);
          }
          if (docChange.type == DocumentChangeType.modified) {
            final collectionIndex = collections.indexWhere((collection) => collection.id == incomingCollection.id);
            collections[collectionIndex] = incomingCollection;
          }
          if (docChange.type == DocumentChangeType.removed) {
            collections.removeWhere((collection) => collection.id == incomingCollection.id);
          }
        });
        _upsertResult(resultIndex, collections);
        cb(accumulatedResult[resultIndex]);
      };
    }(accumulatedResult.length);
  }

  Query query() {
    var query;
    if (searchQuery != null) {
      query = FirebaseFirestore.instance.collection('users').doc(userId).collection("collections")
          .orderBy(orderBy, descending: descending)
          .startAt([searchQuery])
          .endAt(['$searchQuery\uf8ff']);
    } else {
      query = FirebaseFirestore.instance.collection('users').doc(userId).collection("collections").orderBy(orderBy, descending: descending);
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
