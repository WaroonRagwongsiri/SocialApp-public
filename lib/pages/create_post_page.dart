import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:socialapp/service/post_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late File _images;
  final picker = ImagePicker();
  late String _uploadFileURL;

  Future<void> chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _images = File(pickedFile!.path);
    });

    if (pickedFile?.path == null) {
      return;
    }
  }

  Future<void> uploadFile() async {
    _uploadFileURL = '';

    String uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_images.path)}';
    Reference uniqueStorageReference =
        FirebaseStorage.instance.ref().child('images/$uniqueFileName');

    UploadTask uploadTask = uniqueStorageReference.putFile(_images);

    await uploadTask.whenComplete(() => null);

    uniqueStorageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadFileURL = fileURL;
      });
    }).whenComplete(() async {
      PostService().createPost(_uploadFileURL);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(
                padding: const EdgeInsets.all(8),
                height: MediaQuery.of(context).size.height / 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Upload Sucessful ^ ^"),
                    ElevatedButton(
                        onPressed: () => {Navigator.of(context).pop()},
                        child: const Text("OK!"))
                  ],
                ),
              ),
            );
          });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
                onPressed: () => {
                      chooseImage().whenComplete(() => showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Upload ?'),
                              content: Container(
                                height: MediaQuery.of(context).size.height / 3,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(_images),
                                        fit: BoxFit.cover)),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        {Navigator.of(context).pop()},
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () => {
                                          uploadFile(),
                                          Navigator.of(context).pop()
                                        },
                                    child: const Text('Confirm')),
                              ],
                            );
                          }))
                    },
                child: const Icon(Icons.image)),
          )
        ],
      ),
    );
  }
}
