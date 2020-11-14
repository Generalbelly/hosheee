import 'package:html/parser.dart';
import 'package:hosheee/domain/models/url_metadata.dart';
import 'package:hosheee/domain/repositories/url_metadata_repository.dart' as i_url_metadata_repository;

class UrlMetadataRepository implements i_url_metadata_repository.UrlMetadataRepository {

  final amazonUrlRegExp = RegExp(r'https?:\/\/(.*amazon\..*\/.*|.*amzn\..*\/.*|.*a\.co\/.*)');

  Future<UrlMetadata> get(String url, String html) async {
    Map<dynamic, dynamic> data = {
      'lang': null,
      'author': null,
      'title': null,
      'description': null,
      'logo': null,
      'publisher': null,
      'url': null,
      'video': null,
    };

    var targetSelectors = {
      'title': [
        'meta[property="og:title"],content',
        'meta[name="twitter:title"],content',
      ],
      'description': [
        'meta[property="og:description"],content',
        'meta[name="twitter:description"],content',
        'meta[name="description"],content',
        'meta[itemprop="description"],content',
        'meta[itemprop="description"],content',
      ],
      'image': [
        'meta[property="og:image:secure_url"],content',
        'meta[property="og:image:url"],content',
        'meta[property="og:image"],content',
        'meta[name="twitter:image:src"],content'
        'meta[name="twitter:image"],content',
        'meta[itemprop="image"],content',
      ],
    };
    amazonUrlRegExp.hasMatch(url);
    if (amazonUrlRegExp.hasMatch(url)) {
      targetSelectors['title'].addAll([
        '#title',
      ]);
      targetSelectors['description'].addAll([
        '#productDescription',
      ]);
      targetSelectors['image'].addAll([
        '#main-image,src',
        '.a-dynamic-image,data-a-hires',
        '.a-dynamic-image,src',
      ]);
    }
    var document = parse(html);
    targetSelectors.forEach((property, selectors) {
      for (var i = 0; i < selectors.length; i++) {
        final splitValue = selectors[i].split(',');
        // print(splitValue[0]);
        final elements = document.getElementsByTagName(splitValue[0]);
        for (var i = 0; i < elements.length; i++) {
          final element = elements[i];
          // print(element);
          var content = '';
          if (splitValue.length == 2) {
            content = element.attributes[splitValue[1]];
          } else {
            content = element.text;
          }
          if (content != null && content.isNotEmpty) {
            // print('property: ${data[property]}');
            // print('content: $content');
            data[property] = content;
            break;
          }
          if (data[property] != null) {
            break;
          }
        }
        if (data[property] != null) {
          break;
        }
      }
    });

    final title = data["title"];
    if (title != null && title is String) {
      data["title"] = title.trim();
    }

    final description = data["description"];
    if (description != null && description is String) {
      data["description"] = description.trim();
    }

    data["url"] = url;

    return UrlMetadata.fromMap(data);
  }

}
