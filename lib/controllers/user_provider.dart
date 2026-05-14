import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  String _role = 'STAFF'; // Default fallback
  String _nama = '';
  bool _isActive = true;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _userDocSubscription;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProvider() {
    _initAuthListener();
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  User? get currentUser => _currentUser;
  String get role => _role;
  String get nama => _nama;
  bool get isAdmin => _isActive && _role == 'ADMIN';
  bool get isActive => _isActive;
  String get email => _currentUser?.email ?? '';

  // ==========================================================================
  // INIT LISTENER
  // ==========================================================================

  void _initAuthListener() {
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      await _userDocSubscription?.cancel();

      if (user != null && user.email != null) {
        _watchUserData(user.email!);
      } else {
        _role = 'STAFF';
        _nama = '';
        _isActive = true;
      }

      notifyListeners();
    });
  }

  // ==========================================================================
  // FETCH FIRESTORE USER DATA
  // ==========================================================================

  void _watchUserData(String email) {
    _userDocSubscription = _db
        .collection('users')
        .doc(email)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists && doc.data() != null) {
              final data = doc.data()!;
              _role = (data['role'] as String? ?? 'STAFF').toUpperCase();
              _nama = data['nama'] as String? ?? 'User Tidak Dikenal';
              _isActive = data['isActive'] as bool? ?? true;
            } else {
              _role = 'STAFF';
              _nama = email.split('@').first;
              _isActive = true;
            }
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error fetching user data: $error');
            _role = 'STAFF';
            _nama = email.split('@').first;
            _isActive = true;
            notifyListeners();
          },
        );
  }

  // ==========================================================================
  // LOGOUT
  // ==========================================================================

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _role = 'STAFF';
    _nama = '';
    _isActive = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
