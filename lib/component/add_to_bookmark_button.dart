import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/service/post_service.dart';

class AddToBookmarkButton extends StatelessWidget {
  final DocumentReference postRef;
  const AddToBookmarkButton({super.key, required this.postRef});

  @override
  Widget build(BuildContext context) {
    void addToBookmark({required DocumentReference postRef}) {
      PostService().bookmark(postRef: postRef, userId: Auth().currentUser!.uid);
    }

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(Auth().currentUser!.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return const Text('Error');
          }

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data?.data() == null) {
            return const Text('No post data found');
          }

          var postData = userSnapshot.data!.data() as Map<String, dynamic>;
          List bookmarkList = List.from(postData["bookmark"] ?? []);

          IconData bookmark = Icons.bookmark_outline;

          if(bookmarkList.contains(postRef)){
            bookmark = Icons.bookmark;
          }

          return IconButton(
            icon: Icon(bookmark),
            onPressed: () => {addToBookmark(postRef: postRef)},
          );
        });
  }
}
