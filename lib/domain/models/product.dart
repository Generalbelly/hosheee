import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/domain/models/model.dart';

class Product implements Model {

  String id;
  String name;
  String websiteUrl;
  String imageUrl;
  // String videoUrl;
  // String title;
  String description;
  double price;
  String note;
  String provider;
  Timestamp createdAt;
  Timestamp updatedAt;

  Product(this.id, {
    String name,
    String websiteUrl,
    String imageUrl,
    // String videoUrl,
    // String title,
    String description,
    double price,
    String note,
    String provider,
  })
    : this.websiteUrl = websiteUrl,
      this.imageUrl = imageUrl,
      // this.videoUrl = videoUrl,
      // this.title = title,
      this.description = description,
      this.price = price,
      this.note = note,
      this.provider = provider;

  Product.fromMap(Map<String, dynamic> data)
    : id = data['id'],
      name = data['name'],
      websiteUrl = data['websiteUrl'],
      imageUrl = data['imageUrl'],
      // videoUrl = data['videoUrl'],
      // title = data['title'],
      description = data['description'],
      price = data['price'],
      note = data['note'],
      provider = data['provider'],
      createdAt = data['createdAt'],
      updatedAt = data['updatedAt'];

  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'name': name,
      'websiteUrl': websiteUrl,
      'imageUrl': imageUrl,
      // 'videoUrl': videoUrl,
      // 'title': title,
      'description': description,
      'price': price,
      'note': note,
      'provider': provider,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

}
