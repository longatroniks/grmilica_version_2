import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grmilica_version_2/responsive/mobile_screen_layout.dart';
import 'package:grmilica_version_2/responsive/web_screen_layout.dart';
import 'package:grmilica_version_2/utils/colors.dart';
import 'package:image_picker/image_picker.dart';

import '../resources/auth_methods.dart';
import '../responsive/responsive_layout_screen.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/text_field_input.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      bio: _bioController.text,
      username: _usernameController.text,
      file: _image!,
      // file:
    );
    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: Container(), flex: 2),
                  SvgPicture.asset('assets/images/GRMILICA.svg', height: 100),
                  const SizedBox(height: 32),
                  // circular widget to accept and show our selected file
                  Stack(children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                            backgroundColor: Colors.grey,
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                    Positioned(
                      left: 80,
                      bottom: -10,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                        color: redColor,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 64),
                  // username text_field_input
                  TextFieldInput(
                    hintText: 'Enter your username',
                    textInputType: TextInputType.text,
                    textEditingController: _usernameController,
                  ),
                  const SizedBox(height: 24),
                  // email text_field_input
                  TextFieldInput(
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                  ),
                  const SizedBox(height: 24),
                  // password text_field_input
                  TextFieldInput(
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPass: true,
                  ),
                  const SizedBox(height: 24),
                  // bio text_field_input
                  TextFieldInput(
                    hintText: 'Enter your bio',
                    textInputType: TextInputType.text,
                    textEditingController: _bioController,
                  ),
                  const SizedBox(height: 24),
                  //button for login
                  InkWell(
                      onTap: signUpUser,
                      child: Container(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                color: primaryColor,
                              ))
                            : const Text('Sign up'),
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: blueColor,
                        ),
                      )),
                  const SizedBox(height: 12),
                  Flexible(child: Container(), flex: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text("Have an account?"),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      GestureDetector(
                        onTap: navigateToLogin,
                        child: Container(
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  //Transitionioning to signing up
                ])),
      ),
    );
  }
}
