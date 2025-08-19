import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  // Sign up and save user info to Firestore
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await cred.user?.updateDisplayName(displayName);
    }
    final uid = cred.user!.uid;
    await _fire.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  // Login with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Logout
  Future<void> signOut() => _auth.signOut();
}
