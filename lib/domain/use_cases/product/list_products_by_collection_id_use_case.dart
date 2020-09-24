import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/product_repository.dart';
import 'package:wish_list/utils/helpers.dart';

class ListProductsByCollectionIdUseCaseRequest {
  String collectionId;
  String orderBy = 'createdAt';
  bool descending = true;
  int limit = 0;
  Function(ListProductsByCollectionIdUseCaseResponse) callback;

  ListProductsByCollectionIdUseCaseRequest(this.collectionId, this.callback, {String orderBy = 'createdAt', bool descending = true, int limit = 0}):
    this.limit = limit,
    this.descending = descending,
    this.orderBy = orderBy;

  Map<String, dynamic> toMap() {
    return {
      'orderBy': orderBy,
      'descending': descending,
      'limit': limit,
    };
  }
}

class ListProductsByCollectionIdUseCaseResponse {
  List<Product> products = [];
  String message;

  ListProductsByCollectionIdUseCaseResponse({this.products, String message})
    : this.message = message;
}

class ListProductsByCollectionIdUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  ListProductsByCollectionIdUseCase(this._auth, this._productRepository);

  void handle(ListProductsByCollectionIdUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      _productRepository.listByCollectionId(
        user.id,
        request.collectionId,
        (products) => request.callback(ListProductsByCollectionIdUseCaseResponse(
            products: products
        )),
        orderBy: request.orderBy,
        descending: request.descending,
        limit: request.limit,
      );
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      request.callback(ListProductsByCollectionIdUseCaseResponse(
          products: [],
          message: e.toString()
      ));
    }
  }

}
