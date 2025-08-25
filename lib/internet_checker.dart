import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';

class InternetChecker {
  static StreamSubscription? _subscription;

  static void startMonitoring(BuildContext context) {
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      bool hasInternet = await InternetConnectionChecker.instance.hasConnection;

      if (!hasInternet) {
        _showNoInternetDialog(context);
      }
    });
  }

  static void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must exit
      builder: (context) => AlertDialog(
        title: const Text("No Internet Connection"),
        content: const Text("Please check your internet connection."),
        actions: [
          TextButton(
            onPressed: () {
              // Close the app
              Future.delayed(const Duration(milliseconds: 200), () {
                // Use SystemNavigator.pop() for Android, exit(0) as fallback
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 200), () {
                  // Import dart:io for exit(0)
                  // import 'dart:io';
                  // exit(0);
                });
              });
            },
            child: const Text("Close App"),
          ),
        ],
      ),
    );
  }

  static void dispose() {
    _subscription?.cancel();
  }
}