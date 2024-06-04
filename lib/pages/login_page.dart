import 'package:flutter/material.dart';
import 'package:socialapp/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _currentIndex = 0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _errorController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  Future<void> addUser({required String username}) async {
    late String? email;
    late String? uid;
    try {
      email = Auth().currentUser?.email;
      uid = Auth().currentUser?.uid;
      users.doc(uid).set({
        'username': username,
        'email': email,
        'uid': uid,
        'post': [],
        "profilePic":
            "https://firebasestorage.googleapis.com/v0/b/socialapp-a1884.appspot.com/o/placeholder%2Fblank-profile-picture-973460_1280.png?alt=media&token=6fabbf07-24b8-4e43-aa3d-de0c0d9f4eb1",
        "bookmark":[],
        "follower":[],
        "following":[],
      });
    } catch (e) {
      _errorController.text = e.toString();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await Auth().signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _errorController.text = e.toString();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await Auth()
          .createUserWithEmailAndPassword(email: email, password: password);
      await addUser(username: username);
    } catch (e) {
      _errorController.text = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login/Register'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildLoginScreen(),
          _buildRegisterScreen(),
        ],
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.6,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.1,
          left: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('LOGIN'),
            TextFormField(
              decoration: const InputDecoration(hintText: 'email'),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'password'),
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => login(
                email: _emailController.text,
                password: _passwordController.text,
              ),
              child: const Text('Login'),
            ),
            Row(
              children: [
                const Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
            TextField(
              controller: _errorController,
              readOnly: true,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterScreen() {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.6,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.1,
          left: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('REGISTER'),
            TextFormField(
              decoration: const InputDecoration(hintText: 'username'),
              keyboardType: TextInputType.text,
              controller: _usernameController,
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'email'),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'password'),
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => register(
                email: _emailController.text,
                password: _passwordController.text,
                username: _usernameController.text,
              ),
              child: const Text('Register'),
            ),
            Row(
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
            TextField(
              controller: _errorController,
              readOnly: true,
            )
          ],
        ),
      ),
    );
  }
}
