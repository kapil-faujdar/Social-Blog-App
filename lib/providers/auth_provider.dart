import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthState { loading, loggedIn, loggedOut, emailNotVerified }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  User? _user;
  AuthState _authState = AuthState.loading;

  User? get user => _user;
  AuthState get authState => _authState;
  bool get emailVerified => _user?.emailVerified ?? false;

  AuthProvider(this._auth, this._firestore) {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user == null) {
        _authState = AuthState.loggedOut;
      } else if (!user.emailVerified) {
        _authState = AuthState.emailNotVerified;
      } else {
        _authState = AuthState.loggedIn;
      }
      print('AuthProvider: authState set to \\$_authState');
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String profilePicUrl = '',
  }) async {
    _authState = AuthState.loading;
    notifyListeners();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(username);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'profilePicUrl': profilePicUrl,
        'bio': '',
        'followers': [],
        'following': [],
      });
      await userCredential.user?.sendEmailVerification();
      _user = userCredential.user;
      _authState = AuthState.emailNotVerified;
    } catch (e) {
      _authState = AuthState.loggedOut;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _authState = AuthState.loading;
    notifyListeners();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      if (_user != null && !_user!.emailVerified) {
        _authState = AuthState.emailNotVerified;
      } else {
        _authState = AuthState.loggedIn;
      }
    } catch (e) {
      _authState = AuthState.loggedOut;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _auth.currentUser;
    if (_user != null && _user!.emailVerified) {
      _authState = AuthState.loggedIn;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _authState = AuthState.loggedOut;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }
} 
