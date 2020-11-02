import 'package:cloud_functions/cloud_functions.dart';
import 'package:hosheee/domain/models/url_metadata.dart';
import 'package:hosheee/domain/repositories/url_metadata_repository.dart' as i_url_metadata_repository;

class UrlMetadataRepository implements i_url_metadata_repository.UrlMetadataRepository {

  Future<UrlMetadata> get(String url) async {
    final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'fetchUrlMetadata');
    final resp = await callable.call(<String, dynamic>{
      'url': url,
    });
    if (resp.data != null) {
      var data = resp.data;
      var fetchUrlMetadataUsingPuppeteerNeeded = data['image'] == null || data['title'] == null || data['description'] == null;
      if (!fetchUrlMetadataUsingPuppeteerNeeded && data['image'] != null) {
        RegExp exp = new RegExp(r"(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|jpeg|gif|png)");
        fetchUrlMetadataUsingPuppeteerNeeded = !exp.hasMatch(data['image'].toString());
      }
      if (fetchUrlMetadataUsingPuppeteerNeeded) {
        final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'fetchUrlMetadataUsingPuppeteer');
        final resp = await callable.call(<String, dynamic>{
          'url': url,
        });
        data = resp.data;
      }
      data['url'] = url;
      return UrlMetadata.fromMap(data);
    }
    return null;
  }

}
