import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart';
import 'package:wish_list/utils/helpers.dart';

class UpdateCollectionUseCaseRequest {
  String name;

  UpdateCollectionUseCaseRequest(this.name);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class UpdateCollectionUseCaseResponse {
  Collection collection;
  String message;

  UpdateCollectionUseCaseResponse(this.collection, {String message})
    : this.message = message;
}

class UpdateCollectionUseCase {

  Auth _auth;

  CollectionRepository _collectionRepository;

  UpdateCollectionUseCase(this._auth, this._collectionRepository);

  Future<UpdateCollectionUseCaseResponse> handle(UpdateCollectionUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (user is User) {
        final collection = await _collectionRepository.update(
            user.id,
            Collection(_collectionRepository.nextIdentity(), request.name)
        );
        return UpdateCollectionUseCaseResponse(collection);
      }
      throw SignInRequiredException();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return UpdateCollectionUseCaseResponse(null, message: e.toString());
    }
  }

}
