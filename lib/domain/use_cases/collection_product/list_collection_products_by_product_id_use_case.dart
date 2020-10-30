import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection_product.dart';
import 'package:hosheee/domain/models/product.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/collection_product_repository.dart';
import 'package:hosheee/domain/repositories/product_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class ListCollectionProductsByProductIdUseCaseRequest {
  String productId;
  String orderBy;
  bool descending;
  int startIndex;
  int limit;
  Function(ListCollectionProductsByProductIdUseCaseResponse) callback;

  ListCollectionProductsByProductIdUseCaseRequest(this.productId, this.callback, { String orderBy = 'createdAt', bool descending = true, int startIndex = 0, int limit = 0 }):
    this.orderBy = orderBy,
    this.descending = descending,
    this.startIndex = startIndex,
    this.limit = limit;

  Map<String, dynamic> toMap() {
    return {
      'orderBy': orderBy,
      'descending': descending,
      'startIndex': startIndex,
      'limit': limit,
    };
  }
}

class ListCollectionProductsByProductIdUseCaseResponse {
  List<CollectionProduct> collectionProducts = [];
  int startIndex = 0;
  int limit = 0;
  String message;

  ListCollectionProductsByProductIdUseCaseResponse({this.collectionProducts, this.startIndex, this.limit, this.message});
}

class ListCollectionProductsByProductIdUseCase {

  Auth _auth;

  CollectionProductRepository _collectionProductRepository;

  ListCollectionProductsByProductIdUseCase(this._auth, this._collectionProductRepository);

  void handle(ListCollectionProductsByProductIdUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      _collectionProductRepository.listByProductId(
        user.id,
        request.productId,
        (collectionProducts) => request.callback(ListCollectionProductsByProductIdUseCaseResponse(
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
      request.callback(ListCollectionProductsByProductIdUseCaseResponse(
          collectionProducts: [],
          startIndex: request.startIndex,
          limit: request.limit,
          message: e.toString()
      ));
    }
  }

}
