import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'providers/auth_provider.dart' as local_auth;
import 'providers/blog_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/user_profile_screen.dart';
import 'widgets/color_picker_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Try to initialize Firebase only if not already
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // App already initialized, no problem
      debugPrint('Firebase already initialized. Skipping re-initialization.');
    } else {
      rethrow; // Bubble up unexpected Firebase exceptions
    }
  }

  runApp(const BlogApp());
}


class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => local_auth.AuthProvider(FirebaseAuth.instance, FirebaseFirestore.instance)),
        ChangeNotifierProvider(create: (_) => BlogProvider(firestore: FirebaseFirestore.instance)),
        ChangeNotifierProvider(create: (_) => UserProvider(firestore: FirebaseFirestore.instance)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final accent = themeProvider.accentColor ?? Colors.cyan;
          final accentSwatch = MaterialColor(
            accent.value,
            <int, Color>{
              50: accent.withOpacity(0.05),
              100: accent.withOpacity(0.1),
              200: accent.withOpacity(0.2),
              300: accent.withOpacity(0.3),
              400: accent.withOpacity(0.4),
              500: accent,
              600: accent.withOpacity(0.6),
              700: accent.withOpacity(0.7),
              800: accent.withOpacity(0.8),
              900: accent.withOpacity(0.9),
            },
          );
          return MaterialApp(
            title: 'Blog App',
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: accentSwatch,
              scaffoldBackgroundColor: const Color(0xFFE0F7FA),
              colorScheme: ColorScheme.fromSwatch(primarySwatch: accentSwatch).copyWith(
                secondary: accent,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: accent,
                elevation: 1,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: accent.withOpacity(0.3),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                prefixIconColor: accent,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: accent, width: 2),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: accentSwatch,
              scaffoldBackgroundColor: const Color(0xFF101D1E),
              colorScheme: ColorScheme.fromSwatch(
                brightness: Brightness.dark,
                primarySwatch: accentSwatch,
              ).copyWith(
                secondary: accent,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF16282A),
                foregroundColor: accent,
                elevation: 1,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: accent.withOpacity(0.3),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1A2B2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                prefixIconColor: accent,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: accent, width: 2),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const RootController(),
          );
        },
      ),
    );
  }
}

class RootController extends StatelessWidget {
  const RootController({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<local_auth.AuthProvider>(context);
    print('RootController: authState is \\${authProvider.authState}');
    switch (authProvider.authState) {
      case local_auth.AuthState.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case local_auth.AuthState.emailNotVerified:
        return const VerifyEmailScreen();
      case local_auth.AuthState.loggedIn:
        return const BlogHomeScreen();
      case local_auth.AuthState.loggedOut:
        return const LoginScreen();
    }
    // Fallback in case of unexpected state
  }
}

class BlogHomeScreen extends StatelessWidget {
  const BlogHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blogProvider = Provider.of<BlogProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    // Listen to blogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      blogProvider.listenToExploreBlogs();
    });
    final blogs = blogProvider.exploreBlogs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Blogs'),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserProfileScreen(userId: user.uid)),
                );
              }
            },
          ),
        ],
      ),
      body: blogs.isEmpty
          ? const Center(child: Text('No notes yet. Tap + to create one!'))
          : ListView.builder(
              itemCount: blogs.length,
              itemBuilder: (context, i) {
                final blog = blogs[i];
                final isOwner = user != null && blog.authorId == user.uid;
                final isLiked = user != null && blog.likes.contains(user.uid);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(userId: blog.authorId),
                              ),
                            );
                          },
                          child: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) => Text(
                              '@${blog.authorName}',
                              style: TextStyle(
                                fontSize: 13,
                                color: themeProvider.accentColor ?? Colors.cyan,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(blog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Text(blog.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${blog.likes.length}'),
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed: user == null
                              ? null
                              : () async {
                                  if (isLiked) {
                                    await blogProvider.blogService.unlikeBlog(blog.id, user.uid);
                                  } else {
                                    await blogProvider.blogService.likeBlog(blog.id, user.uid);
                                  }
                                },
                        ),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HomeScreen(blog: blog),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
