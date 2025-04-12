import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return userCredential.user;
  }

  Future<User?> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredential.user;
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() => _auth.signOut();

  Future<void> saveUserToFirestore(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'email': user.email,
        'uid': user.uid,
      });
    }
  }
}
