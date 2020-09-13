import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/product_repository.dart';
import 'package:wish_list/utils/helpers.dart';

class ListProductsUseCaseRequest {
  String searchQuery;
  String orderBy = 'createdAt';
  bool descending = false;
  int limit = 0;

  ListProductsUseCaseRequest({String searchQuery, String orderBy = 'createdAt', bool descending = false, int limit = 0}):
    this.limit = limit,
    this.descending = descending,
    this.orderBy = orderBy,
    this.searchQuery = searchQuery;

  Map<String, dynamic> toMap() {
    return {
      'searchQuery': searchQuery,
      'orderBy': orderBy,
      'descending': descending,
      'limit': limit,
    };
  }
}

class ListProductsUseCaseResponse {
  List<Product> products;
  String message;

  ListProductsUseCaseResponse(this.products, {String message})
    : this.message = message;
}

class ListProductsUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  ListProductsUseCase(this._auth, this._productRepository);

  Future<ListProductsUseCaseResponse> handle(ListProductsUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (user is User) {
        final products = await _productRepository.list(
          user.id,
          searchQuery: request.searchQuery,
          orderBy: request.orderBy,
          descending: request.descending,
          limit: request.limit,
        );
        print(products);
        return ListProductsUseCaseResponse(products);
      }
      throw SignInRequiredException();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return ListProductsUseCaseResponse(null, message: e.toString());
    }
  }

}
