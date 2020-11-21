import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/domain/models/model.dart';

class CollectionProduct implements Model {

  String id;
  String productImageUrl;
  String productName;
  String collectionImageUrl;
  String collectionName;
  String productId;
  String collectionId;
  Timestamp createdAt;
  Timestamp updatedAt;

  CollectionProduct(this.id, {
    String productName,
    String productImageUrl,
    String collectionName,
    String collectionImageUrl,
    String productId,
    String collectionId,
  }):
      this.productName = productName,
      this.productImageUrl = productImageUrl,
      this.collectionName = collectionName,
      this.collectionImageUrl = collectionImageUrl,
      this.productId = productId,
      this.collectionId = collectionId;

  CollectionProduct.fromMap(Map<String, dynamic> data)
    : id = data['id'],
      productImageUrl = data['productImageUrl'],
      productName = data['productName'],
      collectionImageUrl = data['collectionImageUrl'],
      collectionName = data['collectionName'],
      productId = data['productId'],
      collectionId = data['collectionId'],
      createdAt = data['createdAt'],
      updatedAt = data['updatedAt'];

  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'collectionName': collectionName,
      'collectionImageUrl': collectionImageUrl,
      'productId': productId,
      'collectionId': collectionId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

  // ui
  String reloadKey = '';

}
