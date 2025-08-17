// Main entry point for the app. Handles Firebase init and routing.
// Written by: Aytan (Intern, 3rd year software student)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/video_list_screen.dart';

// This is needed to make sure Firebase is ready before app starts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Main app widget, sets up theme and routes
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intern Video App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, // I like blue :)
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/videos': (_) => const VideoListScreen(),
      },
      home: const EntryPoint(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Checks if user is logged in or not and shows the right screen
class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If user is not logged in, show login
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        } else {
          // If logged in, go to video list
          return const VideoListScreen();
        }
      },
    );
  }
}
