import 'package:cloud_firestore/cloud_firestore.dart';

class Collection {
  String id;
  String name;
  String imageUrl;
  Timestamp createdAt;
  Timestamp updatedAt;

  Collection(this.id, this.name, {String imageUrl}):
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
