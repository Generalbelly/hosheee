import 'dart:async';
import 'package:wish_list/domain/models/product.dart';

abstract class ProductRepository {

  Future<List<Product>> list(String userId, {String searchQuery, String orderBy = 'createdAt', bool descending = false, int limit = 0});

  Future<Product> get(String userId, String productId);

  Future<Product> add(String userId, Product product);

  Future<Product> update(String userId, Product product);

  Future<Product> delete(String userId, Product product);

  String nextIdentity();

}
