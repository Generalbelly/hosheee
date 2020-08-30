import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart';

class AddCollectionUseCaseRequest {
  Collection collection;

  AddCollectionUseCaseRequest(this.collection);
}

class AddCollectionUseCaseResponse {
  Collection collection;
  String message;

  AddCollectionUseCaseResponse(this.collection, {String message})
    : this.message = message;
}

class AddCollectionUseCase {

  Auth _auth;

  CollectionRepository _collectionRepository;

  AddCollectionUseCase(this._auth, this._collectionRepository);

  Future<AddCollectionUseCaseResponse> handle(AddCollectionUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (user is User) {
        final collection = await _collectionRepository.add(
            user.id,
            Collection(_collectionRepository.nextIdentity(), request.collection.name)
        );
        return AddCollectionUseCaseResponse(collection);
      }
      throw SignInRequiredException();
    } catch (error) {
      print(error);
      return AddCollectionUseCaseResponse(null, message: error.toString());
    }
  }

}
