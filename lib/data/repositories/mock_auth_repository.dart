import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_assets.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  final StreamController<UserModel?> _authController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  
  static const String _prefUserKey = 'ezztrip_mock_user_id';
  static const String _prefUserNameKey = 'ezztrip_mock_user_name';
  static const String _prefUserEmailKey = 'ezztrip_mock_user_email';
  static const String _prefUserPhoneKey = 'ezztrip_mock_user_phone';
  static const String _prefUserPhotoKey = 'ezztrip_mock_user_photo';

  MockAuthRepository() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_prefUserKey);
    if (userId != null) {
      _currentUser = UserModel(
        id: userId,
        name: prefs.getString(_prefUserNameKey) ?? 'John Doe',
        email: prefs.getString(_prefUserEmailKey) ?? 'john.doe@example.com',
        phoneNumber: prefs.getString(_prefUserPhoneKey) ?? '+1234567890',
        photoUrl: prefs.getString(_prefUserPhotoKey) ?? AppAssets.defaultProfileImage,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      _authController.add(_currentUser);
    } else {
      _authController.add(null);
    }
  }

  @override
  Stream<UserModel?> get onAuthStateChanged => _authController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signInWithEmailAndPassword({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Simple password validation check
    if (password.length < 6) {
      throw Exception('Incorrect password. Please try again.');
    }

    _currentUser = UserModel(
      id: 'mock_user_123',
      name: 'John Doe',
      email: email,
      phoneNumber: '+1 234 567 8900',
      photoUrl: AppAssets.defaultProfileImage,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, _currentUser!.id);
    await prefs.setString(_prefUserNameKey, _currentUser!.name);
    await prefs.setString(_prefUserEmailKey, _currentUser!.email);
    await prefs.setString(_prefUserPhoneKey, _currentUser!.phoneNumber);
    await prefs.setString(_prefUserPhotoKey, _currentUser!.photoUrl);

    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    _currentUser = UserModel(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phoneNumber: phone,
      photoUrl: AppAssets.defaultProfileImage,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, _currentUser!.id);
    await prefs.setString(_prefUserNameKey, _currentUser!.name);
    await prefs.setString(_prefUserEmailKey, _currentUser!.email);
    await prefs.setString(_prefUserPhoneKey, _currentUser!.phoneNumber);
    await prefs.setString(_prefUserPhotoKey, _currentUser!.photoUrl);

    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUserKey);
    await prefs.remove(_prefUserNameKey);
    await prefs.remove(_prefUserEmailKey);
    await prefs.remove(_prefUserPhoneKey);
    await prefs.remove(_prefUserPhotoKey);
    
    _authController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulated completion
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulated completion
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    if (_currentUser == null) throw Exception('No user signed in');

    await Future.delayed(const Duration(milliseconds: 1000));
    _currentUser = _currentUser!.copyWith(
      name: name,
      phoneNumber: phone,
      photoUrl: photoUrl,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserNameKey, _currentUser!.name);
    await prefs.setString(_prefUserPhoneKey, _currentUser!.phoneNumber);
    if (photoUrl != null) {
      await prefs.setString(_prefUserPhotoKey, photoUrl);
    }

    _authController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> changePassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // Simulated completion
  }
}
