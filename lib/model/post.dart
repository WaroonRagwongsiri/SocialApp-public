import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String posterId;
  final String imageUrl;
  final Timestamp timestamp;
  final List liked;
  final List comment;

  Post(
      {required this.postId,
      required this.posterId,
      required this.imageUrl,
      required this.timestamp,
      required this.liked,
      required this.comment});

  Map<String, dynamic> toMap() {
    return {
      "postId": postId,
      "posterId": posterId,
      "imageUrl": imageUrl,
      "timestamp": timestamp,
      "liked": liked,
      "comment":comment
    };
  }
}
