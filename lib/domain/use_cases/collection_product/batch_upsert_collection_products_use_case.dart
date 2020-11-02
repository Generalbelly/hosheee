import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/collection_product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class BatchUpsertCollectionProductsUseCaseRequest {
  List<CollectionProduct> collectionProducts;

  BatchUpsertCollectionProductsUseCaseRequest(this.collectionProducts);

  Map<String, dynamic> toMap() {
    return {
      'collectionProduct': collectionProducts,
    };
  }
}

class BatchUpsertCollectionProductsUseCaseResponse {
  String message;

  BatchUpsertCollectionProductsUseCaseResponse({String message})
    : this.message = message;
}

class BatchUpsertCollectionProductsUseCase {

  Auth _auth;

  CollectionProductRepository _collectionProductRepository;

  BatchUpsertCollectionProductsUseCase(this._auth, this._collectionProductRepository);

  Future<BatchUpsertCollectionProductsUseCaseResponse> handle(BatchUpsertCollectionProductsUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _collectionProductRepository.batchUpsert(
          user.id,
          request.collectionProducts.map((collectionProduct) {
            collectionProduct.id = _collectionProductRepository.nextIdentity(collectionProduct.collectionId, collectionProduct.productId);
            return collectionProduct;
          }).toList()
      );
      return BatchUpsertCollectionProductsUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return BatchUpsertCollectionProductsUseCaseResponse(message: e.toString());
    }
  }

}
