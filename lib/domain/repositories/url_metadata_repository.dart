import 'dart:async';
import 'package:wish_list/domain/models/url_metadata.dart';

abstract class UrlMetadataRepository {

  Future<UrlMetadata> get(String url);

}
