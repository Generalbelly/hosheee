import 'package:hosheee/domain/models/collection.dart';

abstract class CollectionRepository {

  void list(String userId, Function(List<Collection>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0});

  Future<Collection> get(String userId, String collectionId);

  Future<void> add(String userId, Collection collection);

  Future<void> update(String userId, Collection collection);

  Future<void> delete(String userId, Collection collection);

  String nextIdentity();
}
