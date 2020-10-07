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
  int startIndex = 0;
  int limit = 0;
  Function(ListCollectionProductsByCollectionIdUseCaseResponse) callback;

  ListCollectionProductsByCollectionIdUseCaseRequest(this.collectionId, this.callback, { this.orderBy, this.descending, this.startIndex, this.limit });

  Map<String, dynamic> toMap() {
    return {
      'orderBy': orderBy,
      'descending': descending,
      'startIndex': startIndex,
      'limit': limit,
    };
  }
}

class ListCollectionProductsByCollectionIdUseCaseResponse {
  List<CollectionProduct> collectionProducts = [];
  int startIndex = 0;
  int limit = 0;
  String message;

  ListCollectionProductsByCollectionIdUseCaseResponse({this.collectionProducts, this.startIndex, this.limit, this.message});
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
          startIndex: request.startIndex,
          limit: request.limit,
        )),
        orderBy: request.orderBy,
        descending: request.descending,
        startIndex: request.startIndex,
        limit: request.limit,
      );
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      request.callback(ListCollectionProductsByCollectionIdUseCaseResponse(
          collectionProducts: [],
          startIndex: request.startIndex,
          limit: request.limit,
          message: e.toString()
      ));
    }
  }

}
