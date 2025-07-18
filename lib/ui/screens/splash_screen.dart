import 'dart:async';

import 'package:examgrid/ui/screens/signUp_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/text_carousel.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        //  const Spacer(flex: 2),
          SizedBox(height: 100,),
          Center(child: Image.asset('images/logo.jpg', height: 300,)), // Put your logo in assets
          const SizedBox(height: 20),
          // const Text(
          //   'ExamGrid',
          //   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 30),
         const TextCarousel(),
          const SizedBox(height: 100,),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                //SignupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffEE9838),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Let's Start", style: TextStyle(fontSize: 18)),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
