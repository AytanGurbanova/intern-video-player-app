// Handles authentication stuff (sign up, login, logout)
// Written by: Aytan (Intern)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  // Sign up with email & password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Set display name if provided
    if (displayName != null && displayName.isNotEmpty) {
      await cred.user?.updateDisplayName(displayName);
    }

    // Save user info to Firestore (not really used in app but good to have)
    final uid = cred.user!.uid;
    await _fire.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  // Login
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() => _auth.signOut();
}
