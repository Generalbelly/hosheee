import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/domain/models/model.dart';

class CollectionProduct implements Model {

  String id;
  String imageUrl;
  String name;
  String productId;
  String collectionId;
  Timestamp createdAt;
  Timestamp updatedAt;

  CollectionProduct(this.id, {
    String name,
    String imageUrl,
    String productId,
    String collectionId,
  }):
      this.name = name,
      this.imageUrl = imageUrl,
      this.productId = productId,
      this.collectionId = collectionId;

  CollectionProduct.fromMap(Map<String, dynamic> data)
    : id = data['id'],
      imageUrl = data['imageUrl'],
      name = data['name'],
      productId = data['productId'],
      collectionId = data['collectionId'],
      createdAt = data['createdAt'],
      updatedAt = data['updatedAt'];

  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'productId': productId,
      'collectionId': collectionId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

}
