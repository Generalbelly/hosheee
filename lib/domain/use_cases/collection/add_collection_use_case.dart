import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart';
import 'package:wish_list/utils/helpers.dart';

class AddCollectionUseCaseRequest {
  Collection collection;

  AddCollectionUseCaseRequest(this.collection);

  Map<String, dynamic> toMap() {
    return {
      'collection': collection.toMap(),
    };
  }
}

class AddCollectionUseCaseResponse {
  String message;

  AddCollectionUseCaseResponse({String message})
    : this.message = message;
}

class AddCollectionUseCase {

  Auth _auth;

  CollectionRepository _collectionRepository;

  AddCollectionUseCase(this._auth, this._collectionRepository);

  Future<AddCollectionUseCaseResponse> handle(AddCollectionUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _collectionRepository.add(
          user.id,
          Collection(_collectionRepository.nextIdentity(), name: request.collection.name)
      );
      return AddCollectionUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return AddCollectionUseCaseResponse(message: e.toString());
    }
  }

}
