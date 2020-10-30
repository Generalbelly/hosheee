import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class AddProductUseCaseRequest {
  Product product;

  AddProductUseCaseRequest(this.product);

  Map<String, dynamic> toMap() {
    return {
      'product': product,
    };
  }
}

class AddProductUseCaseResponse {
  String message;

  AddProductUseCaseResponse({String message})
    : this.message = message;
}

class AddProductUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  AddProductUseCase(this._auth, this._productRepository);

  Future<AddProductUseCaseResponse> handle(AddProductUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      request.product.id = _productRepository.nextIdentity();
      await _productRepository.add(
          user.id,
          request.product
      );
      return AddProductUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return AddProductUseCaseResponse(message: e.toString());
    }
  }

}
