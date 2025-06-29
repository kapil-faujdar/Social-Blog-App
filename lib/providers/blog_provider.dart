import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../services/blog_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogProvider extends ChangeNotifier {
  final BlogService _blogService;
  List<BlogModel> _exploreBlogs = [];
  List<BlogModel> _followingBlogs = [];

  List<BlogModel> get exploreBlogs => _exploreBlogs;
  List<BlogModel> get followingBlogs => _followingBlogs;

  BlogService get blogService => _blogService;

  BlogProvider({required FirebaseFirestore firestore}) : _blogService = BlogService(firestore);

  void listenToExploreBlogs() {
    _blogService.getExploreBlogs().listen((blogs) {
      _exploreBlogs = blogs;
      notifyListeners();
    });
  }

  void listenToFollowingBlogs(List<String> followingUids) {
    _blogService.getFollowingBlogs(followingUids).listen((blogs) {
      _followingBlogs = blogs;
      notifyListeners();
    });
  }

  Future<void> createBlog({required String title, required String content, required String authorId, required String authorName}) async {
    final blog = BlogModel(
      id: '',
      title: title,
      content: content,
      authorId: authorId,
      authorName: authorName,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      likes: [],
    );
    await _blogService.createBlog(blog);
    notifyListeners();
  }

  Future<void> updateBlog(String blogId, {required String title, required String content}) async {
    await _blogService.updateBlog(blogId, {
      'title': title,
      'content': content,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    notifyListeners();
  }

  Future<void> deleteBlog(String blogId) async {
    await _blogService.deleteBlog(blogId);
    notifyListeners();
  }
} 
