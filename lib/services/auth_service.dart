import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        try {
          final user = userCredential.user!;
          final userModel = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'User',
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Check if user exists, if not create new user document
          final existingUser = await _firestoreService.getUser(user.uid);
          if (existingUser == null) {
            await _firestoreService.createUser(userModel);
            print('✅ User created in Firestore successfully');
          } else {
            print('✅ User already exists in Firestore');
          }
        } catch (firestoreError) {
          // Firestore error - authentication still succeeded
          print(
            '⚠️ Warning: Could not save user to Firestore: $firestoreError',
          );
          print(
            'ℹ️ Authentication successful, but Firestore may not be enabled.',
          );
          print('ℹ️ Please follow instructions in ENABLE_FIRESTORE.md');
          // Don't rethrow - authentication was successful
        }
      }

      return userCredential;
    } catch (e) {
      print('❌ Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestoreService.deleteUserData(user.uid);

        // Delete the Firebase Auth account
        await user.delete();

        // Sign out from Google
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
