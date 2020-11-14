import 'package:hosheee/domain/models/auth.dart';
import 'package:hosheee/domain/models/exceptions/sign_in_required_exception.dart';
import 'package:hosheee/domain/models/url_metadata.dart';
import 'package:hosheee/domain/models/user.dart';
import 'package:hosheee/domain/repositories/url_metadata_repository.dart';
import 'package:hosheee/utils/helpers.dart';

class GetUrlMetadataUseCaseRequest {
  String url;
  String html;
  GetUrlMetadataUseCaseRequest(this.url, this.html);

  Map<String, dynamic> toMap() {
    return {
      'url': url,
    };
  }
}

class GetUrlMetadataUseCaseResponse {
  UrlMetadata urlMetadata;
  String message;

  GetUrlMetadataUseCaseResponse(this.urlMetadata, {String message})
      : this.message = message;
}

class GetUrlMetadataUseCase {

  Auth _auth;

  UrlMetadataRepository _urlMetadataRepository;

  GetUrlMetadataUseCase(this._auth, this._urlMetadataRepository);

  Future<GetUrlMetadataUseCaseResponse> handle(GetUrlMetadataUseCaseRequest request) async {
    try {
      final user = await _auth.user();
      if (user is User) {
        final urlMetadata = await _urlMetadataRepository.get(request.url, request.html);
        return GetUrlMetadataUseCaseResponse(urlMetadata);
      }
      throw SignInRequiredException();
    } catch (e) {
      logger().error(e.toString(), {
        'request': request.toMap(),
      });
      return GetUrlMetadataUseCaseResponse(null, message: e.toString());
    }
  }

}
