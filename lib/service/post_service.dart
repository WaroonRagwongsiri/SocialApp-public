import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/model/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(String imageUrl) async {
    final String currentUser = Auth().currentUser!.uid.toString();
    final Timestamp timestamp = Timestamp.now();
    final List liked = [];
    final List comment = [];

    DocumentReference postRef = _firestore.collection("Post").doc();

    Post newPost = Post(
        postId: postRef.id,
        posterId: currentUser,
        imageUrl: imageUrl,
        timestamp: timestamp,
        liked: liked,
        comment: comment);

    DocumentReference userRef = _firestore.collection("Users").doc(currentUser);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      transaction.set(postRef, newPost.toMap());

      if (snapshot.exists) {
        transaction.update(userRef, {
          "post": FieldValue.arrayUnion([postRef])
        });
      }
    });
  }

  Future<List<DocumentReference>> getPost() async {
    List<DocumentReference> postRefList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Post")
        .orderBy("timestamp", descending: true)
        .get();

    for (var doc in querySnapshot.docs) {
      postRefList.add(doc.reference);
    }

    return postRefList;
  }

  Future<void> like({required String postId, required String currentId}) async {
    DocumentReference postRef = _firestore.collection("Post").doc(postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(postRef);

      if (snapshot.exists) {
        List likedList = List.from(snapshot.get("liked"));

        if (likedList.contains(currentId)) {
          likedList.remove(currentId);
        } else {
          likedList.add(currentId);
        }

        transaction.update(postRef, {"liked": likedList});
      }
    });
  }

  Future<void> comment(
      {required String postId,
      required String currentId,
      required String comment}) async {
    DocumentReference postRef = _firestore.collection("Post").doc(postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(postRef);

      if (snapshot.exists) {
        transaction.update(postRef, {
          "comment": FieldValue.arrayUnion([
            {"commentUserId": currentId, "comment": comment}
          ])
        });
      }
    });
  }

  void sharePost({required String postId}) {
    final String shareableLink =
        'https:/example.com/post-detail-page?postId=$postId';
    Share.share(shareableLink, subject: 'Check out this post!');
  }

  Future<void> deletePost({required DocumentReference postRef}) async {
    var data = await postRef.get();
    String imageName = data["imageUrl"];
    imageName = imageName.split('%2F').last.split('?').first;
    Reference storage = FirebaseStorage.instance.ref().child("images/$imageName");

    await _firestore.runTransaction((transaction) async {
      await storage.delete();
      transaction.delete(postRef);
    });
  }

  Future<void> bookmark(
      {required DocumentReference postRef, required String userId}) async {
    DocumentReference userRef = _firestore.collection("Users").doc(userId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (userSnapshot.exists) {
        List bookmark = List.from(userSnapshot.get("bookmark"));

        if (bookmark.contains(postRef)) {
          bookmark.remove(postRef);
        } else {
          bookmark.add(postRef);
        }
        transaction.update(userRef, {"bookmark": bookmark});
      }
    });
  }
}
