import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'New User',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      photoUrl: user.photoURL ?? '',
      createdAt: user.metadata.creationTime,
    );
  }

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(fbUser.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      } catch (e) {
        print("Error fetching user from Firestore: $e");
      }
      return _mapFirebaseUser(fbUser);
    });
  }

  @override
  UserModel? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  @override
  Future<UserModel> signInWithEmailAndPassword({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return _mapFirebaseUser(credential.user)!;
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final fbUser = credential.user!;
    await fbUser.updateDisplayName(name);

    final user = UserModel(
      id: fbUser.uid,
      name: name,
      email: email,
      phoneNumber: phone,
      photoUrl: '',
      createdAt: DateTime.now(),
    );

    // Save user to Firestore 'users' collection
    await _firestore.collection('users').doc(fbUser.uid).set(user.toMap());
    return user;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      await fbUser.sendEmailVerification();
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) throw Exception('No user signed in');

    await fbUser.updateDisplayName(name);
    if (photoUrl != null) {
      await fbUser.updatePhotoURL(photoUrl);
    }

    final updateData = {
      'name': name,
      'phoneNumber': phone,
    };
    if (photoUrl != null) {
      updateData['photoUrl'] = photoUrl;
    }

    await _firestore.collection('users').doc(fbUser.uid).update(updateData);
    
    final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> changePassword(String newPassword) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      await fbUser.updatePassword(newPassword);
    }
  }
}
