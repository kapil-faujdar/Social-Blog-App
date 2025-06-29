import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/blog_provider.dart';
import '../providers/auth_provider.dart' as local_auth;
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _bioController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isEditingBio = false;
  bool _isEditingUsername = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<local_auth.AuthProvider>(context, listen: false).user;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (user != null && userProvider.userModel == null) {
      userProvider.fetchUser(user.uid);
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<local_auth.AuthProvider>(context, listen: false).user;
    final userProvider = Provider.of<UserProvider>(context);
    final blogProvider = Provider.of<BlogProvider>(context);
    final userModel = userProvider.userModel;

    if (user == null || userModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _bioController.text = userModel.bio;
    _usernameController.text = userModel.username;

    // Filter blogs by current user
    final userBlogs = blogProvider.exploreBlogs.where((b) => b.authorId == user.uid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
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
                    child: _isEditingUsername
                        ? TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(labelText: 'Username'),
                          )
                        : Text(userModel.username, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  IconButton(
                    icon: Icon(_isEditingUsername ? Icons.save : Icons.edit),
                    tooltip: _isEditingUsername ? 'Save Username' : 'Edit Username',
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_isEditingUsername) {
                              setState(() => _isSaving = true);
                              await userProvider.updateUsername(user.uid, _usernameController.text.trim());
                              setState(() => _isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Username updated!')),
                              );
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
              const SizedBox(height: 16),
              // Bio
              Row(
                children: [
                  Expanded(
                    child: _isEditingBio
                        ? TextField(
                            controller: _bioController,
                            decoration: const InputDecoration(labelText: 'Bio'),
                          )
                        : Text(userModel.bio.isEmpty ? 'No bio yet.' : userModel.bio),
                  ),
                  IconButton(
                    icon: Icon(_isEditingBio ? Icons.save : Icons.edit),
                    tooltip: _isEditingBio ? 'Save Bio' : 'Edit Bio',
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_isEditingBio) {
                              setState(() => _isSaving = true);
                              await userProvider.updateBio(user.uid, _bioController.text.trim());
                              setState(() => _isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bio updated!')),
                              );
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
                child: Text('My Blogs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
