import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class ListProductsUseCaseRequest {
  String searchQuery;
  String orderBy = 'createdAt';
  bool descending = true;
  int startIndex = 0;
  int limit = 0;
  Function(ListProductsUseCaseResponse) callback;

  ListProductsUseCaseRequest(this.callback, {this.searchQuery, this.orderBy, this.descending, this.startIndex, this.limit});

  Map<String, dynamic> toMap() {
    return {
      'searchQuery': searchQuery,
      'orderBy': orderBy,
      'descending': descending,
      'startIndex': startIndex,
      'limit': limit,
    };
  }
}

class ListProductsUseCaseResponse {
  List<Product> products = [];
  String message;
  int startIndex = 0;
  int limit = 0;

  ListProductsUseCaseResponse({this.products, this.message, this.startIndex, this.limit});
}

class ListProductsUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  ListProductsUseCase(this._auth, this._productRepository);

  void handle(ListProductsUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      _productRepository.list(
        user.id,
        (products) => request.callback(ListProductsUseCaseResponse(
          products: products,
          startIndex: request.startIndex,
          limit: request.limit,
        )),
        searchQuery: request.searchQuery,
        orderBy: request.orderBy,
        descending: request.descending,
        startIndex: request.startIndex,
        limit: request.limit,
      );
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      request.callback(ListProductsUseCaseResponse(
        products: [],
        message: e.toString(),
        startIndex: request.startIndex,
        limit: request.limit,
      ));
    }
  }

}
