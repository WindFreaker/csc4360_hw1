import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  String content;
  Timestamp timestamp;

  PostData({required this.content, required this.timestamp});
}