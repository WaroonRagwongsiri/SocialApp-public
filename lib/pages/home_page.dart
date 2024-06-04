import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/component/post_box.dart';
import 'package:socialapp/service/post_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<DocumentReference>> futurePostRefs;

  @override
  void initState() {
    futurePostRefs = PostService().getPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social App'),
        actions: [
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.message_outlined))
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
            future: futurePostRefs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading posts'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No posts available'));
              }

              List<DocumentReference> listPostRef = snapshot.data!;

              return ListView.builder(
                itemCount: listPostRef.length,
                itemBuilder: (context, index) {
                  return PostBox(postRef: listPostRef[index]);
                },
              );
            },
          )),
        ],
      ),
    );
  }
}
