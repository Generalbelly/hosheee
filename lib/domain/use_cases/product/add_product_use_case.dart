import 'dart:async';
import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/product.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/product_repository.dart';

class AddProductUseCaseRequest {
  Product product;

  AddProductUseCaseRequest(this.product);
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
    } catch (error) {
      print(error);
      return AddProductUseCaseResponse(null, message: error.toString());
    }
  }

}
