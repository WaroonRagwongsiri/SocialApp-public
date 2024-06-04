import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/component/profile_menu.dart';
import 'package:socialapp/component/user_info.dart';
import 'package:socialapp/component/username_text.dart';
import 'package:socialapp/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  void showMenu() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return const ProfileMenu();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserNameText(userId: Auth().currentUser!.uid),
        actions: [
          IconButton(
              onPressed: () => {context.go('/createPost')},
              icon: const Icon(Icons.add_box_outlined)),
          IconButton(
              onPressed: () => {showMenu()}, icon: const Icon(Icons.menu))
        ],
      ),
      body: Column(
        children: [
          UserInfo(userId: Auth().currentUser!.uid),
          ElevatedButton(
              onPressed: () => {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return EditProfilePage(userId: Auth().currentUser!.uid);
                    }))
                  },
              child: const Text("Edit your profile")),
        ],
      ),
    );
  }
}
