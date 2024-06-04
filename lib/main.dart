import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:socialapp/pages/create_post_page.dart';
import 'package:socialapp/pages/detail/post_detail_page.dart';
import 'package:socialapp/pages/detail/user_detail_page.dart';
import 'package:socialapp/pages/home_page.dart';
import 'package:socialapp/pages/login_page.dart';
import 'package:socialapp/pages/profile_page.dart';
import 'package:socialapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socialapp/auth.dart';
import 'package:uni_links2/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    routes: [
      ShellRoute(
          routes: [
            GoRoute(
              path: "/",
              name: "home",
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: "/createPost",
              name: "createPost",
              builder: (context, state) => const CreatePostPage(),
            ),
            GoRoute(
              path: "/profile",
              name: "profile",
              builder: (context, state) => const ProfilePage(),
            ),
          ],
          builder: (context, state, child) {
            return NavigationShell(child: child);
          }),
      GoRoute(
        path: "/user-detail-page",
        name: "user-detail-page",
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId']!;
          return UserDetailPage(userId: userId);
        },
      ),
      GoRoute(
        path: "/post-detail-page",
        name: "post-detail-page",
        builder: (context, state) {
          final postId = state.uri.queryParameters['postId']!;
          return PostDetailPage(postId: postId);
        },
      ),
    ],
  );

  Future<void> _initDeepLinkListener() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      linkStream.listen((String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    if (uri.path == '/user-detail-page') {
      final userId = uri.queryParameters['userId'];
      if (userId != null) {
        _router.go('/user-detail-page?userId=$userId');
      }
    } else if (uri.path == '/post-detail-page') {
      final postId = uri.queryParameters['postId'];
      if (postId != null) {
        _router.go('/post-detail-page?postId=$postId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initDeepLinkListener();
    return StreamBuilder(
        stream: Auth().authStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp.router(
              routerConfig: _router,
              theme: ThemeData.dark(),
            );
          } else {
            return MaterialApp(
              home: const LoginPage(),
              theme: ThemeData.dark(),
            );
          }
        });
  }
}

class NavigationShell extends StatefulWidget {
  final Widget child;

  const NavigationShell({required this.child, super.key});

  @override
  _NavigationShellState createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/createPost');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          ),
        ],
      ),
    );
  }
}
