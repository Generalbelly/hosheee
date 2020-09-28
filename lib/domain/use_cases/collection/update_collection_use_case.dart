import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/collection.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/collection_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class UpdateCollectionUseCaseRequest {
  Collection collection;

  UpdateCollectionUseCaseRequest(this.collection);

  Map<String, dynamic> toMap() {
    return {
      'collection': collection,
    };
  }
}

class UpdateCollectionUseCaseResponse {
  String message;

  UpdateCollectionUseCaseResponse({String message})
      : this.message = message;
}

class UpdateCollectionUseCase {

  Auth _auth;

  CollectionRepository _collectionRepository;

  UpdateCollectionUseCase(this._auth, this._collectionRepository);

  Future<UpdateCollectionUseCaseResponse> handle(UpdateCollectionUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _collectionRepository.update(
          user.id,
          request.collection
      );
      return UpdateCollectionUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return UpdateCollectionUseCaseResponse(message: e.toString());
    }
  }

}
