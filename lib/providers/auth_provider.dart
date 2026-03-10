import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;

    if (user != null) {
      try {
        _userModel = await _firestoreService.getUser(user.uid);
        if (_userModel == null) {
          // User doesn't exist in Firestore yet, create them
          print('📝 Creating new user in Firestore...');
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'User',
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _firestoreService.createUser(newUser);
          _userModel = newUser;
          print('✅ User created successfully');
        } else {
          print('✅ User loaded from Firestore');
        }
      } catch (e) {
        print('⚠️ Firestore Error: $e');
        // Create a temporary user model from Firebase Auth data
        // This allows the app to work even without Firestore
        _userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _error =
            '⚠️ Firestore not enabled. Please follow instructions in ENABLE_FIRESTORE.md';
        print('ℹ️ Using temporary user data from Firebase Auth');
      }
    } else {
      _userModel = null;
    }

    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await _authService.signInWithGoogle();

      if (credential == null) {
        _error = 'Sign in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _firebaseUser = credential.user;
      if (_firebaseUser != null) {
        try {
          _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
        } catch (e) {
          print('Warning: Could not load user data from Firestore: $e');
          // Continue anyway - authentication is still valid
          _userModel = null;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _firebaseUser = null;
      _userModel = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.deleteAccount();
      _firebaseUser = null;
      _userModel = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> updateUserProfile({
    required String displayName,
    String? phone,
    String? linkedIn,
  }) async {
    if (_userModel == null) return false;
    try {
      _isLoading = true;
      notifyListeners();

      _userModel = _userModel!.copyWith(
        displayName: displayName,
        phone: phone,
        linkedIn: linkedIn,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateUser(_userModel!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
