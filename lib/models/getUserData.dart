import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  String uid;
  String? email;
  String? displayName;
  String? avatarUrl;
  String? username;
  String? firstName;
  String? lastName;
  String? docId;

  UserData({
    required this.uid,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.username,
    this.firstName,
    this.lastName,
    this.docId,
  });

  static UserData? _currentUser;

  static void setCurrentUser(UserData userData) {
    _currentUser = userData;
  }

  static UserData? getCurrentUser() {
    return _currentUser;
  }

  factory UserData.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return UserData(
        uid: data['uid'],
        displayName: data['displayName'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        username: data['username'],
        email: data['email'],
        avatarUrl: data['avatarUrl'],
        docId: snapshot.id);
  }

  static UserData empty() {
    return UserData(
        uid: '',
        username: '',
        firstName: '',
        lastName: '',
        email: '',
        avatarUrl: '',
        docId: '');
  }
}
