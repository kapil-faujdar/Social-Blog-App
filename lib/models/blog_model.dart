import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> likes;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
  });

  factory BlogModel.fromMap(Map<String, dynamic> map, String id) {
    return BlogModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likes': likes,
    };
  }
} 
