import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  UserModel? _userModel;

  UserModel? get userModel => _userModel;
  UserService get userService => _userService;

  UserProvider({required FirebaseFirestore firestore}) : _userService = UserService(firestore);

  Future<void> fetchUser(String uid) async {
    _userModel = await _userService.getUserById(uid);
    notifyListeners();
  }

  Future<void> follow(String currentUid, String targetUid) async {
    await _userService.followUser(currentUid, targetUid);
    await fetchUser(currentUid);
  }

  Future<void> unfollow(String currentUid, String targetUid) async {
    await _userService.unfollowUser(currentUid, targetUid);
    await fetchUser(currentUid);
  }

  Future<void> updateBio(String uid, String bio) async {
    await _userService.updateUser(uid, {'bio': bio});
    await fetchUser(uid);
  }

  String? validateUsername(String username) {
    if (username.isEmpty) return 'Username cannot be empty';
    if (!RegExp(r'^[a-z]+$').hasMatch(username)) return 'Username must contain only lowercase letters (a-z)';
    return null;
  }

  Future<void> updateUsername(String uid, String username) async {
    final lowerUsername = username.toLowerCase();
    final error = validateUsername(lowerUsername);
    if (error != null) throw Exception(error);
    if (await _userService.isUsernameTaken(lowerUsername, excludeUid: uid)) {
      throw Exception('Username already taken');
    }
    await _userService.updateUsernameEverywhere(uid, lowerUsername);
    await fetchUser(uid);
  }
} 
 
