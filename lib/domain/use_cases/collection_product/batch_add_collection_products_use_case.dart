import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/collection_product_repository.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class BatchAddCollectionProductsUseCaseRequest {
  List<CollectionProduct> collectionProducts;

  BatchAddCollectionProductsUseCaseRequest(this.collectionProducts);

  Map<String, dynamic> toMap() {
    return {
      'collectionProduct': collectionProducts,
    };
  }
}

class BatchAddCollectionProductsUseCaseResponse {
  String message;

  BatchAddCollectionProductsUseCaseResponse({String message})
    : this.message = message;
}

class BatchAddCollectionProductsUseCase {

  Auth _auth;

  CollectionProductRepository _collectionProductRepository;

  BatchAddCollectionProductsUseCase(this._auth, this._collectionProductRepository);

  Future<BatchAddCollectionProductsUseCaseResponse> handle(BatchAddCollectionProductsUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _collectionProductRepository.batchAdd(
          user.id,
          request.collectionProducts.map((collectionProduct) {
            collectionProduct.id = _collectionProductRepository.nextIdentity();
            return collectionProduct;
          }).toList()
      );
      return BatchAddCollectionProductsUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return BatchAddCollectionProductsUseCaseResponse(message: e.toString());
    }
  }

}
