import 'dart:async';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';

abstract class CollectionProductRepository {

  void listByCollectionId(String userId, String collectionId, Function(List<CollectionProduct>) callback, {String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0});

  Future<void> add(String userId, CollectionProduct collectionProduct);

  Future<void> batchAdd(String userId, List<CollectionProduct> collectionProducts);

  Future<void> batchDelete(String userId, List<CollectionProduct> collectionProducts);

  String nextIdentity();

}
