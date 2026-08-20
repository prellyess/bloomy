import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== LOGIN ====================
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (userDoc.exists) {
        return result.user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== REGISTER ====================
  Future<User?> registerUser(Map<String, dynamic> userData) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': userData['email'],
        'fullname': userData['fullname'],
        'phone': userData['phone'],
        'role': userData['role'] ?? 'USER',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return result.user;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}