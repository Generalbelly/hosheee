import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/collection_product_repository.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class BatchDeleteCollectionProductsUseCaseRequest {
  List<CollectionProduct> collectionProducts;

  BatchDeleteCollectionProductsUseCaseRequest(this.collectionProducts);

  Map<String, dynamic> toMap() {
    return {
      'collectionProduct': collectionProducts,
    };
  }
}

class BatchDeleteCollectionProductsUseCaseResponse {
  String message;

  BatchDeleteCollectionProductsUseCaseResponse({String message})
    : this.message = message;
}

class BatchDeleteCollectionProductsUseCase {

  Auth _auth;

  CollectionProductRepository _collectionProductRepository;

  BatchDeleteCollectionProductsUseCase(this._auth, this._collectionProductRepository);

  Future<BatchDeleteCollectionProductsUseCaseResponse> handle(BatchDeleteCollectionProductsUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _collectionProductRepository.batchDelete(
          user.id,
          request.collectionProducts,
      );
      return BatchDeleteCollectionProductsUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return BatchDeleteCollectionProductsUseCaseResponse(message: e.toString());
    }
  }

}
