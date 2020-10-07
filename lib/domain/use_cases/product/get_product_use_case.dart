import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class GetProductUseCaseRequest {
  String productId;

  GetProductUseCaseRequest(this.productId);

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
    };
  }
}

class GetProductUseCaseResponse {
  String message;
  Product product;

  GetProductUseCaseResponse(this.product, {String message})
    : this.message = message;
}

class GetProductUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  GetProductUseCase(this._auth, this._productRepository);

  Future<GetProductUseCaseResponse> handle(GetProductUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      final product = await _productRepository.get(
          user.id,
          request.productId,
      );
      return GetProductUseCaseResponse(product);
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return GetProductUseCaseResponse(null, message: e.toString());
    }
  }

}
