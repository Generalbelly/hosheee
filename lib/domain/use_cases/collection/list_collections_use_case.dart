import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/collection_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class ListCollectionsUseCaseRequest {
  String searchQuery;
  String orderBy = 'createdAt';
  bool descending = true;
  int limit = 0;
  int startIndex = 0;
  Function(ListCollectionsUseCaseResponse) callback;

  ListCollectionsUseCaseRequest(this.callback, {this.searchQuery, this.orderBy, this.descending, this.startIndex, this.limit});

  Map<String, dynamic> toMap() {
    return {
      'searchQuery': searchQuery,
      'orderBy': orderBy,
      'descending': descending,
      'limit': limit,
      'startIndex': startIndex,
    };
  }
}

class ListCollectionsUseCaseResponse {
  List<Collection> collections = [];
  String message;
  int limit = 0;
  int startIndex = 0;

  ListCollectionsUseCaseResponse({this.collections, this.message, this.startIndex, this.limit});
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
          collections: collections,
          startIndex: request.startIndex,
          limit: request.limit,
        )),
        searchQuery: request.searchQuery,
        orderBy: request.orderBy,
        descending: request.descending,
        startIndex: request.startIndex,
        limit: request.limit,
      );
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      request.callback(ListCollectionsUseCaseResponse(
        collections: [],
        message: e.toString(),
        startIndex: request.startIndex,
        limit: request.limit,
      ));
    }
  }

}
