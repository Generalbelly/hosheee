import 'dart:async';
import 'package:hosheee/domain/models/product.dart';

abstract class ProductRepository {

  void listByCollectionId(String userId, String collectionId, Function(List<Product>) callback, {String orderBy = 'createdAt', bool descending = true, int limit = 0});

  void list(String userId, Function(List<Product>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0});

  Future<Product> get(String userId, String productId);

  Future<void> add(String userId, Product product);

  Future<void> update(String userId, Product product);

  Future<void> delete(String userId, Product product);

  String nextIdentity();

}
