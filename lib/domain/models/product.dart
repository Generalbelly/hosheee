class Product {
  String id;
  String name;
  String websiteUrl;
  String imageUrl;
  String title;
  String description;
  String note;
  double price;
//  Timestamp createdAt;
//  Timestamp updatedAt;

  Product(this.id, this.name, {String websiteUrl, String imageUrl, String title, String description, String note, double price})
    : this.websiteUrl = websiteUrl,
      this.imageUrl = imageUrl,
      this.title = title,
      this.description = description,
      this.note = note,
      this.price = price;

  Product.fromMap(Map<String, dynamic> data)
    : id = data['id'],
      name = data['name'],
      websiteUrl = data['websiteUrl'],
      imageUrl = data['imageUrl'],
      title = data['title'],
      description = data['description'],
      note = data['note'],
      price = data['price'];

  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'name': name,
      'websiteUrl': websiteUrl,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'note': note,
      'price': price,
    };

}
