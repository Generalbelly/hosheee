import 'dart:async';
import 'package:hosheee/domain/models/product.dart';

abstract class ProductRepository {

  void list(String userId, Function(List<Product>) callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0});

  Future<Product> get(String userId, String productId);

  Future<void> add(String userId, Product product);

  Future<void> update(String userId, Product product);

  Future<void> delete(String userId, Product product);

  String nextIdentity();

}
