import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password, {bool rememberMe = true}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Default: simpan kredensial kecuali rememberMe = false
      if (rememberMe) {
        await _saveCredentials(email, password);
      } else {
        await _clearSavedCredentials();
      }
      
      notifyListeners();
      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<bool> autoSignIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');
      
      if (savedEmail != null && savedPassword != null) {
        // Coba login dengan kredensial tersimpan
        await signInWithEmailAndPassword(savedEmail, savedPassword);
        
        // Jika berhasil sampai di sini tanpa exception, artinya login sukses
        debugPrint('Auto sign in successful');
        return true;
      }
      debugPrint('No saved credentials found for auto sign in');
      return false;
    } catch (e) {
      debugPrint('Auto sign in failed: ${e.toString()}');
      // Jika login gagal, hapus kredensial yang tersimpan
      await _clearSavedCredentials();
      return false;
    }
  }
  
  // Save credentials to SharedPreferences
  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    debugPrint('Credentials saved for user: $email');
  }
  
  // Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    debugPrint('Saved credentials cleared');
  }
  
  // Sign out and clear credentials
  Future<void> signOut({bool clearCredentials = false}) async {
    // Default: jangan hapus kredensial saat logout kecuali diminta secara eksplisit
    if (clearCredentials) {
      await _clearSavedCredentials();
    }
    await _auth.signOut();
    notifyListeners();
  }
  
  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userType,
    String? nik,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        await _createUserData(user.uid, {
          'email': email,
          'name': name,
          'phone': phone,
          'userType': userType,
          'nik': nik,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Setelah registrasi berhasil, simpan kredensial secara otomatis
      await _saveCredentials(email, password);
      
      notifyListeners();
      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Create user data in Firestore
  Future<void> _createUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }
  
  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    // Add updatedAt timestamp
    data['updatedAt'] = FieldValue.serverTimestamp();
    
    await _firestore.collection('users').doc(uid).update(data);
    notifyListeners();
  }
  
  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      final uid = currentUser?.uid;
      
      if (uid == null) {
        return null;
      }
      
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      return UserModel.fromJson(docSnapshot.data()!, uid);
    } catch (e) {
      debugPrint('Error getting user data: ${e.toString()}');
      return null;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Handle Firebase Auth exceptions with friendly error messages
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found for that email.');
        case 'wrong-password':
          return Exception('Wrong password provided for that user.');
        case 'email-already-in-use':
          return Exception('The email address is already in use by another account.');
        case 'weak-password':
          return Exception('The password provided is too weak.');
        case 'invalid-email':
          return Exception('The email address is badly formatted.');
        case 'user-disabled':
          return Exception('This user account has been disabled.');
        default:
          return Exception('An error occurred: ${e.message}');
      }
    }
    return Exception('An unexpected error occurred.');
  }
}