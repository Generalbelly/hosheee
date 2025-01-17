import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class DeleteProductUseCaseRequest {
  Product product;

  DeleteProductUseCaseRequest(this.product);

  Map<String, dynamic> toMap() {
    return {
      'product': product,
    };
  }
}

class DeleteProductUseCaseResponse {
  String message;

  DeleteProductUseCaseResponse({String message})
    : this.message = message;
}

class DeleteProductUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  DeleteProductUseCase(this._auth, this._productRepository);

  Future<DeleteProductUseCaseResponse> handle(DeleteProductUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _productRepository.delete(
          user.id,
          request.product
      );
      return DeleteProductUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return DeleteProductUseCaseResponse(message: e.toString());
    }
  }

}
