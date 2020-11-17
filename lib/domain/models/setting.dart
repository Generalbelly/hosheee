import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hosheee/domain/models/model.dart';

class Setting implements Model {

  String id;
  int themeColor = 0xff2196f3;
  String fontFamily;
  Timestamp createdAt;
  Timestamp updatedAt;

  Setting(this.id, {
    String fontFamily,
  })
    : this.fontFamily = fontFamily;

  Setting.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        themeColor = data['themeColor'],
        fontFamily = data['fontFamily'],
        createdAt = data['createdAt'],
        updatedAt = data['updatedAt'];

    Map<String, dynamic> toMap() =>
      {
        'id': id,
        'themeColor': themeColor,
        'fontFamily': fontFamily,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

}
