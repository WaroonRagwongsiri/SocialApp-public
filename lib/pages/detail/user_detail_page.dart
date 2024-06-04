import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/component/user_info.dart';
import 'package:socialapp/component/username_text.dart';
import 'package:socialapp/service/profile_service.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  void follow({required String userId}) {
    ProfileService()
        .follow(userId: widget.userId, currentUserId: Auth().currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserNameText(userId: widget.userId),
      ),
      body: Column(
        children: [
          UserInfo(userId: widget.userId),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(Auth().currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return const Text('No user data found');
                }

                var currentUserData =
                    snapshot.data!.data() as Map<String, dynamic>;

                if (currentUserData["following"].contains(widget.userId)) {
                  return unfollowButton();
                }
                return followButton();
              }),
        ],
      ),
    );
  }

  Widget unfollowButton() {
    return ElevatedButton(
      onPressed: () => {follow(userId: widget.userId)},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 20),
        shape: RoundedRectangleBorder(
            side: BorderSide.none, borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        "following",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget followButton() {
    return ElevatedButton(
        onPressed: () => {follow(userId: widget.userId)},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 20),
          shape: RoundedRectangleBorder(
              side: BorderSide.none, borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Follow",
          style: TextStyle(color: Colors.white),
        ));
  }
}
