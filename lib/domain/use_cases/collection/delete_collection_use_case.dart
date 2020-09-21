import 'package:wish_list/domain/models/auth.dart';
import 'package:wish_list/domain/models/collection.dart';
import 'package:wish_list/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:wish_list/domain/models/user.dart';
import 'package:wish_list/domain/repositories/collection_repository.dart';
import 'package:wish_list/utils/helpers.dart';

class DeleteCollectionUseCaseRequest {
  Collection collection;

  DeleteCollectionUseCaseRequest(this.collection);

  Map<String, dynamic> toMap() {
    return {
      'collection': collection,
    };
  }
}

class DeleteCollectionUseCaseResponse {
  String message;

  DeleteCollectionUseCaseResponse({String message})
    : this.message = message;
}

class DeleteCollectionUseCase {

  Auth _auth;

  CollectionRepository _collectionRepository;

  DeleteCollectionUseCase(this._auth, this._collectionRepository);

  Future<DeleteCollectionUseCaseResponse> handle(DeleteCollectionUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (!(user is User)) {
        throw SignInRequiredException();
      }
      await _collectionRepository.delete(
          user.id,
          request.collection
      );
      return DeleteCollectionUseCaseResponse();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return DeleteCollectionUseCaseResponse(message: e.toString());
    }
  }

}
