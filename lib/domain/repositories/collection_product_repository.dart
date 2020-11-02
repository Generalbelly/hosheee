import 'dart:async';
import 'package:hosheee/domain/models/collection_product.dart';

abstract class CollectionProductRepository {

  void listByCollectionId(String userId, String collectionId, Function(List<CollectionProduct>) callback, {String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0});

  void listByProductId(String userId, String productId, Function(List<CollectionProduct>) callback, {String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0});

  Future<void> add(String userId, CollectionProduct collectionProduct);

  Future<void> batchUpsert(String userId, List<CollectionProduct> collectionProducts);

  Future<void> batchDelete(String userId, List<CollectionProduct> collectionProducts);

  String nextIdentity(String collectionId, String productId);

}
