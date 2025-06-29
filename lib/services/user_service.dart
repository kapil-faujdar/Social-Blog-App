import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _userCollection;
  final FirebaseFirestore _firestore;

  UserService(FirebaseFirestore firestore)
      : _firestore = firestore,
        _userCollection = firestore.collection('users');

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _userCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _userCollection.doc(uid).update(data);
  }

  Future<void> followUser(String currentUid, String targetUid) async {
    await _userCollection.doc(currentUid).update({
      'following': FieldValue.arrayUnion([targetUid]),
    });
    await _userCollection.doc(targetUid).update({
      'followers': FieldValue.arrayUnion([currentUid]),
    });
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    await _userCollection.doc(currentUid).update({
      'following': FieldValue.arrayRemove([targetUid]),
    });
    await _userCollection.doc(targetUid).update({
      'followers': FieldValue.arrayRemove([currentUid]),
    });
  }

  Future<bool> isUsernameTaken(String username, {String? excludeUid}) async {
    final lowerUsername = username.toLowerCase();
    final query = await _userCollection
      .where('username', isEqualTo: lowerUsername)
      .get();
    if (excludeUid != null) {
      return query.docs.any((doc) => doc.id != excludeUid);
    }
    return query.docs.isNotEmpty;
  }

  Future<void> updateUsernameEverywhere(String uid, String newUsername) async {
    final lowerUsername = newUsername.toLowerCase();
    // Update in user doc
    await _userCollection.doc(uid).update({'username': lowerUsername});
    // Update in all blogs
    final blogCollection = _firestore.collection('blogs');
    final userBlogs = await blogCollection.where('authorId', isEqualTo: uid).get();
    for (final doc in userBlogs.docs) {
      await doc.reference.update({'authorName': lowerUsername});
    }
  }
} 
