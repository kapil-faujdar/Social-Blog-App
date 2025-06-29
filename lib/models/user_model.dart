class UserModel {
  final String uid;
  final String email;
  final String username;
  final String profilePicUrl;
  final String bio;
  final List<String> followers;
  final List<String> following;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.profilePicUrl,
    required this.bio,
    required this.followers,
    required this.following,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profilePicUrl: map['profilePicUrl'] ?? '',
      bio: map['bio'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
    };
  }
} 
