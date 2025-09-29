import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _ensureProfile(cred.user);
    return cred;
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _ensureProfile(cred.user);
    return cred;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For web, use Firebase Auth with Google provider
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');

        // For web, we need to use signInWithPopup or signInWithRedirect
        final userCredential = await _auth.signInWithPopup(provider);
        await _ensureProfile(userCredential.user);
        return userCredential;
      } else {
        // For mobile/desktop, use GoogleSignIn package
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google sign in canceled by user');
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        await _ensureProfile(userCredential.user);
        return userCredential;
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      if (e.toString().contains('popup_closed_by_user') ||
          e.toString().contains('canceled')) {
        throw Exception('Google sign-in was canceled');
      }
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<void> _ensureProfile(User? user) async {
    if (user == null) return;

    final pRef = _db.child('users/${user.uid}/profile');
    final snap = await pRef.get();

    if (!snap.exists) {
      await pRef.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastLogin': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      // Update last login time
      await pRef.update({
        'lastLogin': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  User? get currentUser => _auth.currentUser;
}
