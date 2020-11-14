import 'package:hosheee/domain/models/url_metadata.dart';

abstract class UrlMetadataRepository {

  Future<UrlMetadata> get(String url, String html);

}
