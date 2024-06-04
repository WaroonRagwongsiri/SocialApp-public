import 'package:flutter/material.dart';
import 'package:socialapp/service/profile_service.dart';

class UserNameText extends StatelessWidget {
  final String userId;
  const UserNameText({super.key,required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
            future:
                ProfileService().getUserName(userId: userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading profile'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No profile available'));
              }
              return Text(snapshot.data!);
            });
  }
}