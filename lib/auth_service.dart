import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  static const _serverClientId =
      '797671553506-76ajap3njhcm4lcuqt2oefbuvg4hva06.apps.googleusercontent.com';
  final GoogleSignIn _google = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _google.initialize(
      clientId: _serverClientId,
      serverClientId: _serverClientId,
    );
    _initialized = true;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final cred = await _auth.signInWithPopup(provider);
        await _ensureUserDoc(cred.user);
        return cred;
      }

      await _ensureInitialized();

      GoogleSignInAccount? user;
      if (_google.supportsAuthenticate()) {
        user = await _google.authenticate();
      } else {
        user = await _google.attemptLightweightAuthentication(
          reportAllExceptions: true,
        );
      }

      if (user == null) return null;

      final auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      final cred = await _auth.signInWithCredential(credential);
      await _ensureUserDoc(cred.user);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _google.signOut();
      }
    } finally {
      await _auth.signOut();
    }
  }

  // Email/password registration
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null && photoURL.isNotEmpty) {
          await user.updatePhotoURL(photoURL);
        }
        await _ensureUserDoc(user);
        await user.sendEmailVerification();
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  // Email/password sign-in
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDoc(cred.user);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  // Send verification email to current user
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    await user.sendEmailVerification();
  }

  // Reload user to refresh emailVerified flag
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Create a user document if missing
  Future<void> _ensureUserDoc(User? user) async {
    if (user == null) return;
    final ref = _db.collection('users').doc(user.uid);
    final exists = await ref.get().then((s) => s.exists);
    if (!exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'providerIds': user.providerData.map((p) => p.providerId).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
