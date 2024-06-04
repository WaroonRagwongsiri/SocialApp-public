import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/pages/detail/user_detail_page.dart';
import 'package:socialapp/service/post_service.dart';
import 'package:socialapp/service/profile_service.dart';

class CommentsBox extends StatelessWidget {
  final DocumentReference postRef;
  const CommentsBox({super.key, required this.postRef});

  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();

    void addComment({required String postId, required String comment}) {
      if (comment.isNotEmpty) {
        PostService().comment(
            postId: postId,
            currentId: Auth().currentUser!.uid,
            comment: comment);
        commentController.clear();
      }
    }

    return StreamBuilder(
      stream: postRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Text('No post data found');
        }

        var postData = snapshot.data!.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> comments = List.from(postData["comment"]);
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 5.0,
                width: 40.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              const Text(
                'Comments',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                        future: ProfileService().getUserData(
                            userId: comments[index]["commentUserId"]),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (userSnapshot.hasError) {
                            return const Center(
                                child: Text('Error loading profile'));
                          }

                          if (!userSnapshot.hasData ||
                              userSnapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No profile available'));
                          }
                          var posterData = userSnapshot.data!;
                          return ListTile(
                            title: GestureDetector(
                              child: Text(
                                posterData["username"],
                                textAlign: TextAlign.left,
                              ),
                              onTap: () => {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return UserDetailPage(
                                      userId: posterData["uid"]);
                                }))
                              },
                            ),
                            leading: GestureDetector(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(120),
                                child: Image.network(
                                  posterData["profilePic"],
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              onTap: () => {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return UserDetailPage(
                                      userId: posterData["uid"]);
                                }))
                              },
                            ),
                            subtitle: Text(comments[index]["comment"]),
                          );
                        });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => addComment(
                          postId: postData["postId"],
                          comment: commentController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
