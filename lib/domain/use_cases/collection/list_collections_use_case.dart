import 'package:wish_list/adapter/gateway/auth.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart';

class ListCollectionsUseCaseRequest {
  ListCollectionsUseCaseRequest();
}

class ListCollectionsUseCaseResponse {
  List<Collection> collections;
  String message;

  ListCollectionsUseCaseResponse(this.collections, {String message})
    : this.message = message;
}

class ListCollectionsUseCase {

  Auth _auth;

  CollectionRepository _collectionRepository;

  ListCollectionsUseCase(this._auth, this._collectionRepository);

  Future<ListCollectionsUseCaseResponse> handle(ListCollectionsUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (user is User) {
        final collections = await _collectionRepository.list(user.id);
        return ListCollectionsUseCaseResponse(collections);
      }
      throw SignInRequiredException();
    } catch (error) {
      print(error);
      return ListCollectionsUseCaseResponse(null, message: error.toString());
    }
  }

}
