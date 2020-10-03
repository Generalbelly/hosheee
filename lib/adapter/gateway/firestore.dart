import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/domain/models/model.dart';
import 'dart:async';

abstract class QueryManager {
  DocumentSnapshot lastVisible;
  List<StreamSubscription> _listeners = [];

  bool isSubsequentTo(QueryManager qm);
  bool isEqualTo(QueryManager qm);
  List<Model> getCombinedResult();
  Function(QuerySnapshot snapshot) getSnapshotHandler(Function cb);
  Query query();
  void detachListeners() {
    _listeners.forEach((listListener) async { await listListener.cancel(); });
  }
  void attachListener(StreamSubscription listener) {
    _listeners.add(listener);
  }
}
