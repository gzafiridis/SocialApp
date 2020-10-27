import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth extends ChangeNotifier {
  String _userId;
  String _userRole;
  String _userName;
  String _userEmail;
  String _userPhoto;
  String _userStory;

  User _user;

  User get user => _user;
  String get userRole => _userRole;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userId => _userId;
  String get userPhoto => _userPhoto;
  String get userStory => _userStory;

  
  setStory(String newStory) async {
    _userStory = newStory;
    notifyListeners();
  }

  login(String email, String password) async {
    UserCredential authResult = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    if (authResult != null) {
      User firebaseUser = authResult.user;

      if (firebaseUser != null) {
        print("Log In: $firebaseUser");
        _user = firebaseUser;
        _userId = firebaseUser.uid;
        _userEmail = email;
        final response = await FirebaseFirestore.instance
            .collection('patients')
            .doc(_userId)
            .get();
        if (response.data() == null) {
          final response = await FirebaseFirestore.instance
              .collection('doctors')
              .doc(_userId)
              .get();
          if (response.data() == null) {
            print('Could not find doc for user');
            return;
          }
          _userStory = response.data()['story'];
          _userPhoto = response.data()['photo'];
          _userRole = 'doctor';
          _userName = response.data()['username'];
          notifyListeners();
          return;
        }
        _userStory = response.data()['story'];
        _userPhoto = response.data()['photo'];
        _userRole = 'patient';
        _userName = response.data()['username'];
        notifyListeners();
        return;
      }
    }
  }

  signup(String email, String password, String role, String username) async {
    UserCredential authResult = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    if (authResult != null) {
      User firebaseUser = authResult.user;
      if (firebaseUser != null) {
        print("Sign up: $firebaseUser");
        User currentUser = FirebaseAuth.instance.currentUser;
        _user = currentUser;
        _userId = currentUser.uid;
        _userName = username;
        _userEmail = email;
        if (role == 'patient') {
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(_userId)
              .set({'role': role, 'username': username, 'email': email, 'story': ''});
          _userRole = role;
        } else {
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(_userId)
              .set({'role': role, 'username': username, 'email': email, 'story': ''});
          _userRole = role;
        }
        notifyListeners();
      }
    }
  }

  fetchData() async {
    _user = FirebaseAuth.instance.currentUser;
    _userId = _user.uid;
    _userEmail = _user.email;
    final response = await FirebaseFirestore.instance
        .collection('patients')
        .doc(_userId)
        .get();
    if (response.data() == null) {
      final response = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_userId)
          .get();
      if (response.data() == null) {
        print('Could not find doc for user');
        return;
      }
      _userStory = response.data()['story'];
      _userPhoto = response.data()['photo'];
      _userRole = 'doctor';
      _userName = response.data()['username'];
      notifyListeners();
      return;
    }
    _userStory = response.data()['story'];
    _userPhoto = response.data()['photo'];
    _userRole = 'patient';
    _userName = response.data()['username'];
    notifyListeners();
    return;
  }

  signout() async {
    await FirebaseAuth.instance
        .signOut()
        .catchError((error) => print(error.code));
    _user = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    notifyListeners();
  }
}
