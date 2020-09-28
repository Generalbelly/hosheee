import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/domain/models/model.dart';

class Product implements Model {

  String id;
  String name;
  String websiteUrl;
  String imageUrl;
  // String videoUrl;
  // String title;
  // String description;
  String note;
  double price;
  String provider;
  String collectionId;
  Timestamp createdAt;
  Timestamp updatedAt;

  Product(this.id, {
    String name,
    String websiteUrl,
    String imageUrl,
    // String videoUrl,
    // String title,
    // String description,
    String note,
    double price,
    String provider,
    String collectionId
  })
    : this.websiteUrl = websiteUrl,
      this.imageUrl = imageUrl,
      // this.videoUrl = videoUrl,
      // this.title = title,
      // this.description = description,
      this.note = note,
      this.price = price,
      this.provider = provider,
      this.collectionId = collectionId;

  Product.fromMap(Map<String, dynamic> data)
    : id = data['id'],
      name = data['name'],
      websiteUrl = data['websiteUrl'],
      imageUrl = data['imageUrl'],
      // videoUrl = data['videoUrl'],
      // title = data['title'],
      // description = data['description'],
      note = data['note'],
      price = data['price'],
      provider = data['provider'],
      collectionId = data['collectionId'],
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
      // 'description': description,
      'note': note,
      'price': price,
      'provider': provider,
      'collectionId': collectionId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

}
