import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> signUp(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user!.sendEmailVerification();
      await _createUserProfile(cred.user!);
      return AppUser(uid: cred.user!.uid, email: email);
    } catch (e) {
      print(e);  // For debugging, in prod use better error handling
      return null;
    }
  }

  Future<AppUser?> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await cred.user!.reload();
      if (!cred.user!.emailVerified) {
        throw 'Email not verified';
      }
      return AppUser(uid: cred.user!.uid, email: email);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> _createUserProfile(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}