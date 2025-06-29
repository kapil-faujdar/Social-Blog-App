import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/blog_provider.dart';
import '../providers/auth_provider.dart' as local_auth;
import 'home_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _bioController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isEditingBio = false;
  bool _isEditingUsername = false;
  bool _isSaving = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    print('UserProfileScreen initState for userId: \\${widget.userId}');
    Provider.of<UserProvider>(context, listen: false).fetchUser(widget.userId);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('UserProfileScreen build for userId: \\${widget.userId}');
    final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    final userProvider = Provider.of<UserProvider>(context);
    final blogProvider = Provider.of<BlogProvider>(context);
    final userModel = userProvider.userModel;
    final isCurrentUser = currentUser != null && currentUser.uid == widget.userId;

    if (userModel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('User not found or cannot be loaded.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false).fetchUser(widget.userId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Only update controllers if the user changed
    if (userModel.uid != _lastUserId) {
      _bioController.text = userModel.bio;
      _usernameController.text = userModel.username;
      _lastUserId = userModel.uid;
    }

    // Filter blogs by this user
    final userBlogs = blogProvider.exploreBlogs.where((b) => b.authorId == userModel.uid).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'My Profile' : userModel.username),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await Provider.of<local_auth.AuthProvider>(context, listen: false).logout();
                if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: userModel.profilePicUrl.isNotEmpty
                      ? NetworkImage(userModel.profilePicUrl)
                      : null,
                  child: userModel.profilePicUrl.isEmpty
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // Username
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: isCurrentUser && _isEditingUsername
                        ? TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(labelText: 'Username'),
                          )
                        : Text(userModel.username, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  if (isCurrentUser)
                    IconButton(
                      icon: Icon(_isEditingUsername ? Icons.save : Icons.edit),
                      tooltip: _isEditingUsername ? 'Save Username' : 'Edit Username',
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_isEditingUsername) {
                                setState(() => _isSaving = true);
                                try {
                                  await userProvider.updateUsername(userModel.uid, _usernameController.text.trim());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Username updated!')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                                  );
                                }
                                setState(() => _isSaving = false);
                              }
                              setState(() => _isEditingUsername = !_isEditingUsername);
                            },
                    ),
                ],
              ),
              // Email
              Text(userModel.email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              // Followers/Following
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text('${userModel.followers.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Followers'),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      Text('${userModel.following.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Following'),
                    ],
                  ),
                ],
              ),
              if (!isCurrentUser && currentUser != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton(
                    onPressed: () async {
                      final isFollowing = userModel.followers.contains(currentUser.uid);
                      if (isFollowing) {
                        await userProvider.unfollow(currentUser.uid, userModel.uid);
                      } else {
                        await userProvider.follow(currentUser.uid, userModel.uid);
                      }
                    },
                    child: Text(userModel.followers.contains(currentUser.uid) ? 'Unfollow' : 'Follow'),
                  ),
                ),
              const SizedBox(height: 16),
              // Bio
              Row(
                children: [
                  Expanded(
                    child: isCurrentUser && _isEditingBio
                        ? TextField(
                            controller: _bioController,
                            decoration: const InputDecoration(labelText: 'Bio'),
                          )
                        : Text(userModel.bio.isEmpty ? 'No bio yet.' : userModel.bio),
                  ),
                  if (isCurrentUser)
                    IconButton(
                      icon: Icon(_isEditingBio ? Icons.save : Icons.edit),
                      tooltip: _isEditingBio ? 'Save Bio' : 'Edit Bio',
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_isEditingBio) {
                                setState(() => _isSaving = true);
                                try {
                                  await userProvider.updateBio(userModel.uid, _bioController.text.trim());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Bio updated!')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error updating bio: $e')),
                                  );
                                }
                                setState(() => _isSaving = false);
                              }
                              setState(() => _isEditingBio = !_isEditingBio);
                            },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Blogs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 8),
              userBlogs.isEmpty
                  ? const Center(child: Text('No blogs yet.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userBlogs.length,
                      itemBuilder: (context, i) {
                        final blog = userBlogs[i];
                        return Card(
                          child: ListTile(
                            title: Text(blog.title),
                            subtitle: Text(blog.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCurrentUser)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit Blog',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeScreen(blog: blog),
                                        ),
                                      );
                                    },
                                  ),
                                if (isCurrentUser)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Delete Blog',
                                    onPressed: () async {
                                      await blogProvider.deleteBlog(blog.id);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Blog deleted!')),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 
