import 'package:flutter/material.dart';
import 'package:socialapp/auth.dart';
import 'package:socialapp/pages/bookmark_page.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text("Bookmarked"),
            onTap: () => {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BookmarkPage()))
            },
          ),
          ListTile(
            title: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => {Auth().signOut()},
          ),
        ],
      ),
    );
  }
}
