import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgrid/ui/screens/home_screen.dart';
import 'package:examgrid/ui/screens/auth/signUp_screen.dart';
import 'package:examgrid/ui/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';

import '../../network_connectivity.dart';
import '../widgets/text_carousel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkInternetAndExit(context);
    });
    _checkLoginStatus();
  }
  void checkInternetAndExit(BuildContext context) async {
    final hasNet = await NetworkChecker.hasInternet();

    if (!hasNet) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("No Internet"),
          content: const Text("Please check your internet connection."),
          actions: [
            TextButton(
              onPressed: () {
                exit(0); // Force close app
              },
              child: const Text("Close App"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // splash duration

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _navigateToSignUp();
      return;
    }

    final localSessionId = await secureStorage.read(key: 'session_id');
    final firestoreSessionId = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((doc) => doc.data()?['session_id']);

    if (localSessionId != null && localSessionId == firestoreSessionId) {
      _navigateToHome();
    } else {
      await FirebaseAuth.instance.signOut();
      await secureStorage.delete(key: 'session_id');
      _navigateToSignUp();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,title: const Center(child: Text('Examgrid',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),)),),
      backgroundColor: Colors.white,
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 180,),
          //const Spacer(),
          Lottie.asset(
            'animations/animation.json',
            height: 250,
            repeat: true,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'Get ready for JKSSB JE Civil',
            style: const TextStyle(fontSize: 30, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          const Spacer(),
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: LinearProgressIndicator(color:Theme.of(context).colorScheme.primary,),
          ),
          const SizedBox(height: 100,),
          //const Spacer(),
        ],
      ),
    );
  }
}