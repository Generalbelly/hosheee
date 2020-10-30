import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Model {
  String id;
  Timestamp createdAt;
  Timestamp updatedAt;
}
