import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart';
import 'package:wish_list/utils/helpers.dart';

class ListCollectionsUseCaseRequest {
  String searchQuery;
  String orderBy = 'createdAt';
  bool descending = true;
  int limit = 0;
  Function(ListCollectionsUseCaseResponse) callback;

  ListCollectionsUseCaseRequest(this.callback, {String searchQuery, String orderBy = 'createdAt', bool descending = true, int limit = 0}):
        this.limit = limit,
        this.descending = descending,
        this.orderBy = orderBy,
        this.searchQuery = searchQuery;

  Map<String, dynamic> toMap() {
    return {
      'searchQuery': searchQuery,
      'orderBy': orderBy,
      'descending': descending,
      'limit': limit,
    };
  }
}

class ListCollectionsUseCaseResponse {
  List<Collection> collections = [];
  String message;

  ListCollectionsUseCaseResponse({this.collections, String message})
      : this.message = message;
}

class ListCollectionsUseCase {

  Auth _auth;

  CollectionRepository _collectionRepository;

  ListCollectionsUseCase(this._auth, this._collectionRepository);

  void handle(ListCollectionsUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      _collectionRepository.list(
        user.id,
        (collections) => request.callback(ListCollectionsUseCaseResponse(
          collections: collections
        )),
        searchQuery: request.searchQuery,
        orderBy: request.orderBy,
        descending: request.descending,
        limit: request.limit,
      );
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      request.callback(ListCollectionsUseCaseResponse(
          collections: [],
          message: e.toString()
      ));
    }
  }

}
