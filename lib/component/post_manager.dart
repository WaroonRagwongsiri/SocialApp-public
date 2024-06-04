import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/service/post_service.dart';

class PostManager extends StatelessWidget {
  final DocumentReference postRef;
  final String userId;
  const PostManager({super.key, required this.postRef, required this.userId});

  void deletePost(
      {required DocumentReference postRef, required BuildContext context}) {
    PostService().deletePost(postRef: postRef);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: postRef.snapshots(),
        builder: (context, postSnapshot) {
          if (postSnapshot.hasError) {
            return const Text('Error');
          }

          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!postSnapshot.hasData || postSnapshot.data?.data() == null) {
            return const Text('No post data found');
          }

          var postData = postSnapshot.data!.data() as Map<String, dynamic>;
          if (postData["posterId"] == userId) {
            return poster(context);
          }
          return normal();
        });
  }

  Widget poster(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.bookmark_outline),
          title: const Text("Report"),
          tileColor: Colors.red,
          onTap: () => {},
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text("Delete Post"),
          tileColor: Colors.red,
          onTap: () => {deletePost(postRef: postRef, context: context)},
        ),
      ],
    );
  }

  Widget normal() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.bookmark_outline),
          title: const Text("Report"),
          tileColor: Colors.red,
          onTap: () => {},
        ),
      ],
    );
  }
}
