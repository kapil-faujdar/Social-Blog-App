# Social-Blog-App

# 📝 SocialBlog App

> A full-stack Flutter + Firebase blogging platform with auth, user profiles, likes, and followers — built for creators, by a creator.

---

## 🙌 About the Creator

- 👨‍💻 Built by **Kapil** — a product-minded full-stack dev, hustler.
- 🚀 Passionate about building impact-first products with clean UX and scalable architecture.
- 🇮🇳 Based in India, building for the world.
- 🛠️ This project is an MVP-grade showcase of modern mobile architecture using Flutter & Firebase.

---
## 📸 Screenshots

<p float="left">
  <img src="https://github.com/user-attachments/assets/af47223c-b84e-4d93-b748-f6618bae9ace" width="150"/>
  <img src="https://github.com/user-attachments/assets/f65b9bd7-33ae-4e21-bd5c-335532da5cd3" width="150"/>
  <img src="https://github.com/user-attachments/assets/1a4c4970-ec41-481a-a412-f3d286191e3a" width="150"/>
  <img src="https://github.com/user-attachments/assets/f5e4a09d-c664-402e-8231-fb4ce06082b9" width="150"/>
  <img src="https://github.com/user-attachments/assets/dcb10ff2-bd81-4486-8190-9181ebcf11d4" width="150"/>
  <img src="https://github.com/user-attachments/assets/06ea07a5-44c9-4187-9d05-4071d314faa8" width="150"/>
  <img src="https://github.com/user-attachments/assets/f93e691b-0549-4f42-908f-40df6768a8bb" width="150"/>
</p>

## 🎥 Demo Video

https://github.com/user-attachments/assets/ca08b4d8-7fa0-4396-b9e5-a9b6af94360d

---

## 🚀 Core Features Implemented

### 🔐 Authentication
- Email & password-based **Sign Up** and **Login**
- Unique **username** requirement during sign up
- Post-signup **email verification flow** (Firebase Auth)
- Restricted access: only verified users can use the app
- Secure logout

---

### 📰 Community Blog System
- **Explore screen** showing all public blogs from all users
- Blogs display:
  - Author name
  - Blog title and preview
  - Like count and interaction
- Users can:
  - Like/unlike any blog
  - Tap blogs to view full content
  - Access author profiles from blogs

---

### ✍️ Blog Management
- Authenticated users can:
  - **Create new blog posts**
  - **Edit and delete** only their own blogs
- Blog posts support:
  - Title, content, and optional image URL

---

### 👤 User Profiles
- Profile page shows:
  - Username, bio, avatar
  - Follower & following count
  - All blogs posted by the user
- Users can:
  - **Edit their own profile** (username, bio)
  - **Follow/unfollow** other users
  - View other users' profiles and their public blogs

---

## 🧱 Tech Stack

### 💻 Frontend
- **Flutter (Dart)** – Cross-platform UI toolkit for Android (Web/iOS ready)
- **Provider** – Lightweight, scalable state management
- **Google Fonts** – Custom typography
- **Lottie** – Smooth onboarding animations

### 🔥 Backend & Cloud
- **Firebase Authentication** – Email/password auth with email verification
- **Cloud Firestore** – Real-time NoSQL database for blogs, users, comments

### 📦 Utilities & Libraries
- **cached_network_image** – Efficient image loading and caching
- **uuid** – Unique ID generation for blogs/comments
- **flutter_spinkit** – Loading indicators

### 🧪 Dev & Tooling
- **Flutter Test** – Unit/widget test support
- **Flutter Lints** – Code quality and best practices
- **flutter_launcher_icons** – Custom app icon generation

---

## **📦 Firestore Schemas**

**1. users Collection**

Each document represents a user and is identified by their Firebase Auth UID.

{
"uid": "string",                // User's UID (same as document ID)
"email": "string",              // User's email address
"username": "string",           // Unique, lowercase username
"profilePicUrl": "string",      // URL to profile picture (can be empty)
"bio": "string",                // User's bio (can be empty)
"followers": ["uid1", ...],     // Array of UIDs who follow this user
"following": ["uid2", ...]      // Array of UIDs this user follows
}

**2. blogs Collection**

Each document represents a blog post.

{
"authorId": "string",           // UID of the author
"authorName": "string",         // Username of the author (denormalized for display)
"title": "string",              // Blog title
"content": "string",            // Blog content
"createdAt": Timestamp,         // Firestore timestamp of creation
"updatedAt": Timestamp,         // Firestore timestamp of last update
"likes": ["uid1", "uid2", ...]  // Array of UIDs who liked this blog
}

**Notes:**

- All usernames are unique and lowercase.
- Follower/following relationships are managed via arrays of UIDs in the user documents.
- Blog likes are managed via an array of UIDs in each blog document.
- Timestamps use Firestore’s Timestamp type.
