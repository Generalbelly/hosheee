import 'package:cloud_functions/cloud_functions.dart';
import 'package:wish_list/domain/models/url_metadata.dart';
import 'package:wish_list/domain/repositories/url_metadata_repository.dart' as i_url_metadata_repository;

class UrlMetadataRepository implements i_url_metadata_repository.UrlMetadataRepository {

  Future<UrlMetadata> get(String url) async {
    final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'fetchUrlMetadata');
    final resp = await callable.call(<String, dynamic>{
      'url': url,
    });
    return resp.data != null ? UrlMetadata.fromMap(resp.data) : null;
  }

}
