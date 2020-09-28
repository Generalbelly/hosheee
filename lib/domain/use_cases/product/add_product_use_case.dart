import 'dart:async';
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
  Product product;
  String message;

  AddProductUseCaseResponse(this.product, {String message})
    : this.message = message;
}

class AddProductUseCase {

  Auth _auth;

  ProductRepository _productRepository;

  AddProductUseCase(this._auth, this._productRepository);

  Future<AddProductUseCaseResponse> handle(AddProductUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (user is User) {
        final product = await _productRepository.add(
            user.id,
            Product(_productRepository.nextIdentity(), request.product.name)
        );
        return AddProductUseCaseResponse(product);
      }
      throw SignInRequiredException();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return AddProductUseCaseResponse(null, message: e.toString());
    }
  }

}
