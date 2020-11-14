import 'package:flutter_test/flutter_test.dart';
import 'package:hosheee/adapter/gateway/url_metadata/url_metadata_repository.dart';

void main() {
  test("fetchUrlMetadata", () async {
    final urlMetadataRepository = UrlMetadataRepository();
    final urlMetadata = await urlMetadataRepository.get('http://www.so-suke.com/shopdetail/000000001432/');
    print(urlMetadata.title);
    print(urlMetadata.description);
    print(urlMetadata.url);
    print(urlMetadata.image);
    print(urlMetadata.lang);
    print(urlMetadata.author);
    print(urlMetadata.publisher);
    print(urlMetadata.video);
  });
}
