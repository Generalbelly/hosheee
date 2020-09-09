class Product {
  String id;
  String name;
  String websiteUrl;
  String imageUrl;
  String videoUrl;
  String title;
  String description;
  String note;
  double price;
  String provider;
  String collectionId;
//  Timestamp createdAt;
//  Timestamp updatedAt;

  Product(this.id, this.name, {String websiteUrl, String imageUrl, String videoUrl, String title, String description, String note, double price, String provider, String collectionId})
    : this.websiteUrl = websiteUrl,
      this.imageUrl = imageUrl,
      this.title = title,
      this.description = description,
      this.note = note,
      this.price = price,
      this.provider = provider,
      this.collectionId = collectionId;

  Product.fromMap(Map<String, dynamic> data)
    : id = data['id'],
      name = data['name'],
      websiteUrl = data['websiteUrl'],
      imageUrl = data['imageUrl'],
      videoUrl = data['videoUrl'],
      title = data['title'],
      description = data['description'],
      note = data['note'],
      price = data['price'],
      provider = data['provider'],
      collectionId = data['collectionId'];

  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'name': name,
      'websiteUrl': websiteUrl,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'title': title,
      'description': description,
      'note': note,
      'price': price,
      'provider': provider,
      'collectionId': collectionId,
    };

}
