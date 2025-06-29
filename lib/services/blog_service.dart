import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blog_model.dart';

class BlogService {
  final CollectionReference _blogCollection;

  BlogService(FirebaseFirestore firestore)
      : _blogCollection = firestore.collection('blogs');

  Stream<List<BlogModel>> getExploreBlogs() {
    return _blogCollection.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => BlogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList(),
    );
  }

  Stream<List<BlogModel>> getFollowingBlogs(List<String> followingUids) {
    return _blogCollection.where('authorId', whereIn: followingUids).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => BlogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList(),
    );
  }

  Future<void> createBlog(BlogModel blog) async {
    await _blogCollection.add(blog.toMap());
  }

  Future<void> updateBlog(String blogId, Map<String, dynamic> data) async {
    await _blogCollection.doc(blogId).update(data);
  }

  Future<void> deleteBlog(String blogId) async {
    await _blogCollection.doc(blogId).delete();
  }

  Future<void> likeBlog(String blogId, String userId) async {
    await _blogCollection.doc(blogId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unlikeBlog(String blogId, String userId) async {
    await _blogCollection.doc(blogId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }
} 
