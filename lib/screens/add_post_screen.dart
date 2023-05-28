import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grmilica_version_2/resources/firestore_methods.dart';
import 'package:grmilica_version_2/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:grmilica_version_2/providers/user_provider.dart';
import 'package:grmilica_version_2/models/user.dart' as userModel;

import '../utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void postImage(
    String uid,
    String username,
    String image,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        image,
      );

      if (res == 'success') {
        setState(() {
          _isLoading = false;
        });
        showSnackBar('Posted', context);
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(e.toString(), context);
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a Post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void clearImage(){
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel.User user = Provider.of<UserProvider>(context).getUser;
    return _file == null
        ? Center(
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _selectImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: secondaryColor),
                onPressed: clearImage,
              ),
              title: const Text(
                'Post to',
                style: TextStyle(color: secondaryColor),
              ),
              centerTitle: false,
              actions: [
                TextButton(
                    onPressed: () =>
                        postImage(user.uid, user.username, user.photoUrl),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                          color: redColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0)),
                const Divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          backgroundImage: NetworkImage(
                        user.photoUrl,
                      )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Write a caption...',
                            border: InputBorder.none,
                          ),
                          maxLines: 8,
                        ),
                      ),
                      SizedBox(
                          height: 45,
                          width: 45,
                          child: AspectRatio(
                              aspectRatio: 487 / 451,
                              child: Container(
                                  decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(_file!),
                                  fit: BoxFit.fill,
                                  alignment: FractionalOffset.topCenter,
                                ),
                              )))),
                      const Divider(),
                    ]),
              ],
            ),
          );
  }
}
