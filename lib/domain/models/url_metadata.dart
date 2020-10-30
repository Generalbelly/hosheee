class UrlMetadata {
  String lang;
  String author;
  String title;
  String publisher;
  String image;
  String description;
  String logo;
  String url;
  String video;

  UrlMetadata.fromMap(Map<dynamic, dynamic> data)
    :
      lang = data['lang'],
      author = data['author'],
      title = data['title'],
      publisher = data['publisher'],
      image = data['image'],
      description = data['description'],
      logo = data['logo'],
      url = data['url'],
      video = data['video'];

}
