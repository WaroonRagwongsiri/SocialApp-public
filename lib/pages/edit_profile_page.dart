import 'package:flutter/material.dart';
import 'package:socialapp/service/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();

  void save({required Map<String, dynamic> userData}) {
    userData["username"] = _usernameController.text;
    ProfileService()
        .editUserData(userId: widget.userId, editedUserData: userData);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit your Profile"),
        ),
        body: FutureBuilder(
            future: ProfileService().getUserData(userId: widget.userId),
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
              var userData = snapshot.data!;
              _usernameController.text = userData["username"];
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: Image.network(
                      userData["profilePic"],
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  TextFormField(
                    controller: _usernameController,
                  ),
                  ElevatedButton(
                      onPressed: () => {save(userData: userData)},
                      child: const Text("Save")),
                ],
              );
            }));
  }
}
