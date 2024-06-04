import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/component/add_to_bookmark_button.dart';
import 'package:socialapp/component/comments.dart';
import 'package:socialapp/component/post_manager.dart';
import 'package:socialapp/pages/detail/user_detail_page.dart';
import 'package:socialapp/service/post_service.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socialapp/service/profile_service.dart';

class PostBox extends StatelessWidget {
  final DocumentReference postRef;
  const PostBox({super.key, required this.postRef});

  @override
  Widget build(BuildContext context) {
    void showComments() {
      showMaterialModalBottomSheet(
          context: context,
          builder: (context) => CommentsBox(postRef: postRef));
    }

    void sharePost({required String postId}) {
      PostService().sharePost(postId: postId);
    }

    void showPostManager({required String userId}) {
      showMaterialModalBottomSheet(
          context: context,
          builder: (context) => PostManager(
                postRef: postRef,
                userId: userId,
              ));
    }

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

          IconData likeIcon = Icons.favorite_border_outlined;
          if (postData["liked"].contains(Auth().currentUser!.uid)) {
            likeIcon = Icons.favorite;
          }
          return Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                      future: ProfileService()
                          .getUserData(userId: postData["posterId"]),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert_rounded),
                            onPressed: () => {
                              showPostManager(userId: Auth().currentUser!.uid)
                            },
                          ),
                        );
                      }),
                  Image.network(
                    postData["imageUrl"],
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.scaleDown,
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => {
                                PostService().like(
                                    postId: postData["postId"],
                                    currentId: Auth().currentUser!.uid)
                              },
                          icon: Icon(likeIcon)),
                      IconButton(
                          onPressed: () => {showComments()},
                          icon: const Icon(Icons.comment)),
                      IconButton(
                          onPressed: () =>
                              {sharePost(postId: postData["postId"])},
                          icon: const Icon(Icons.send)),
                      const Expanded(child: SizedBox()),
                      AddToBookmarkButton(postRef: postRef),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.all(8),
                    child: Row(
                      children: [
                        Text("${postData["liked"].length.toString()} likes"),
                      ],
                    ),
                  )
                ],
              ));
        });
  }
}
