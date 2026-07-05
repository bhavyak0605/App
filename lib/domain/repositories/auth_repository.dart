import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get onAuthStateChanged;
  UserModel? get currentUser;
  
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
  });

  Future<void> changePassword(String newPassword);
}
