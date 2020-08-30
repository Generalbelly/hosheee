import 'dart:async';
import 'package:wish_list/domain/models/collection.dart';

abstract class CollectionRepository {

  Future<List<Collection>> list(String userId, {String searchQuery, String orderBy = 'createdAt', bool descending = false, int limit = 0});

  Future<Collection> get(String userId, String collectionId);

  Future<Collection> add(String userId, Collection coll);

  Future<Collection> update(String userId, Collection coll);

  Future<Collection> delete(String userId, Collection coll);

  String nextIdentity();

}
