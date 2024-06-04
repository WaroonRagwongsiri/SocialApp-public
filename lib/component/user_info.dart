import 'package:flutter/material.dart';
import 'package:socialapp/service/profile_service.dart';

class UserInfo extends StatelessWidget {
  final String userId;
  const UserInfo({super.key,required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
        const SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: ProfileService().getUserData(userId: userId),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading profile'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No profile available'));
              }
              var userData = snapshot.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: Image.network(
                      userData["profilePic"],
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        const Text("Post"),
                        Text(userData["post"].length.toString())
                      ],
                    ),
                    onTap: () => {},
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        const Text("Follower"),
                        Text(userData["follower"].length.toString())
                      ],
                    ),
                    onTap: () => {},
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        const Text("Following"),
                        Text(userData["following"].length.toString())
                      ],
                    ),
                    onTap: () => {},
                  ),
                ],
              );
            })),
      ]);
  }
}