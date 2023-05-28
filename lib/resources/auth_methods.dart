import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grmilica_version_2/models/user.dart' as model;
import 'package:grmilica_version_2/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        //add user to database
        model.User user = model.User(
          email: email,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          username: username,
          bio: bio,
          followers: [],
          following: [],
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        res = "success";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          res = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          res = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          res = 'The email address is badly formatted.';
          break;
        default:
          res = 'An undefined Error happened.';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter email and password';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          res = 'The email address is badly formatted.';
          break;
        case 'user-not-found':
          res =
              'There is no user record corresponding to this identifier. The user may have been deleted.';
          break;
        case 'wrong-password':
          res = 'The password is invalid or the user does not have a password.';
          break;
        default:
          res = 'An undefined Error happened.';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
