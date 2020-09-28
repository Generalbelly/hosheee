import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wish_list/domain/models/model.dart';

class Collection implements Model {
  String id;
  String name;
  String imageUrl;
  Timestamp createdAt;
  Timestamp updatedAt;

  Collection(this.id, {String name, String imageUrl}):
    name = name,
    imageUrl = imageUrl;

  Collection.fromMap(Map<String, dynamic> data)
    : id = data['id'],
      name = data['name'],
      createdAt = data['createdAt'],
      updatedAt = data['updatedAt'];

  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };

}
