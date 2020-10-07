import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/collection_product_repository.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class ListCollectionProductsByCollectionIdUseCaseRequest {
  String collectionId;
  String orderBy = 'createdAt';
  bool descending = true;
  int limit = 0;
  Function(ListCollectionProductsByCollectionIdUseCaseResponse) callback;

  ListCollectionProductsByCollectionIdUseCaseRequest(this.collectionId, this.callback, {String orderBy = 'createdAt', bool descending = true, int limit = 0}):
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

class ListCollectionProductsByCollectionIdUseCaseResponse {
  List<CollectionProduct> collectionProducts = [];
  String message;

  ListCollectionProductsByCollectionIdUseCaseResponse({this.collectionProducts, String message})
    : this.message = message;
}

class ListCollectionProductsByCollectionIdUseCase {

  Auth _auth;

  CollectionProductRepository _collectionProductRepository;

  ListCollectionProductsByCollectionIdUseCase(this._auth, this._collectionProductRepository);

  void handle(ListCollectionProductsByCollectionIdUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      _collectionProductRepository.listByCollectionId(
        user.id,
        request.collectionId,
        (collectionProducts) => request.callback(ListCollectionProductsByCollectionIdUseCaseResponse(
            collectionProducts: collectionProducts,
        )),
        orderBy: request.orderBy,
        descending: request.descending,
        limit: request.limit,
      );
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      request.callback(ListCollectionProductsByCollectionIdUseCaseResponse(
          collectionProducts: [],
          message: e.toString()
      ));
    }
  }

}
