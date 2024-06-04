import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/component/post_box.dart';
import 'package:socialapp/service/profile_service.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  Future<List<DocumentReference>> getBookmarkPost() async {
    Map<String, dynamic> userData =
        await ProfileService().getUserData(userId: Auth().currentUser!.uid);

    List<DocumentReference> bookmarkPostRefs =
        List<DocumentReference>.from(userData["bookmark"]);

    return bookmarkPostRefs;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bookmarked"),
        ),
        body: FutureBuilder(
          future: getBookmarkPost(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading bookmark'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No bookmark available'));
            }
            List<DocumentReference> listPostRef = snapshot.data!;

            return ListView.builder(
              itemCount: listPostRef.length,
              itemBuilder: (context, index) {
                return PostBox(postRef: listPostRef[index]);
              },
            );
          },
        ));
  }
}
