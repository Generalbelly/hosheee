import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class UpdateProductUseCaseRequest {
  Product product;

  UpdateProductUseCaseRequest(this.product);

  Map<String, dynamic> toMap() {
    return {
      'product': product,
    };
  }
}

class UpdateProductUseCaseResponse {
  String message;

  UpdateProductUseCaseResponse({String message})
    : this.message = message;
}

class UpdateProductUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  UpdateProductUseCase(this._auth, this._productRepository);

  Future<UpdateProductUseCaseResponse> handle(UpdateProductUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _productRepository.update(
          user.id,
          request.product
      );
      return UpdateProductUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return UpdateProductUseCaseResponse(message: e.toString());
    }
  }

}
