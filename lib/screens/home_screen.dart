import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blog_model.dart';
import '../providers/blog_provider.dart';
import '../providers/auth_provider.dart' as local_auth;
import '../providers/theme_provider.dart';
import '../widgets/color_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  final BlogModel? blog;
  const HomeScreen({super.key, this.blog});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.blog != null) {
      _titleController.text = widget.blog!.title;
      _contentController.text = widget.blog!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveBlog() async {
    setState(() => _isLoading = true);
    final user = Provider.of<local_auth.AuthProvider>(context, listen: false).user;
    if (user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a blog.')),
      );
      return;
    }
    final blogProvider = Provider.of<BlogProvider>(context, listen: false);
    try {
      if (widget.blog == null) {
        await blogProvider.createBlog(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          authorId: user.uid,
          authorName: user.displayName ?? '',
        );
      } else {
        await blogProvider.updateBlog(
          widget.blog!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBlog() async {
    if (widget.blog == null) return;
    setState(() => _isLoading = true);
    final blogProvider = Provider.of<BlogProvider>(context, listen: false);
    await blogProvider.deleteBlog(widget.blog!.id);
    if (mounted) Navigator.pop(context);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blog == null ? 'Create Blog' : 'Edit Blog'),
        actions: [
          if (widget.blog != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteBlog,
            ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              IconData icon;
              String tooltip;
              switch (themeProvider.themeMode) {
                case ThemeMode.light:
                  icon = Icons.wb_sunny_rounded;
                  tooltip = 'Light Mode';
                  break;
                case ThemeMode.dark:
                  icon = Icons.nightlight_round;
                  tooltip = 'Dark Mode';
                  break;
                default:
                  icon = Icons.brightness_auto_rounded;
                  tooltip = 'System Mode';
              }
              return IconButton(
                icon: Icon(icon, color: themeProvider.accentColor ?? Colors.cyan),
                tooltip: 'Toggle Theme ($tooltip)',
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(Icons.palette_rounded, color: themeProvider.accentColor ?? Colors.cyan),
              tooltip: 'Customize Colors',
              onPressed: () async {
                final newColor = await showModalBottomSheet<Color?>(
                  context: context,
                  builder: (context) => ColorPickerSheet(),
                );
                if (newColor != null) {
                  themeProvider.setAccentColor(newColor);
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBlog,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.blog == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
} 
