import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String baseUrl = 'https://api.examgrid.space';

  Future<bool> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      print('OTP API response: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('OTP send failed');
      }
    } catch (e) {
      print('sendOtp error: $e');
      rethrow;
    }
  }

  Future<void> saveUserToLocal(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: "user_name", value: userData['firstName'] ?? "");
    await _secureStorage.write(key: "user_email", value: userData['email'] ?? "");
    await _secureStorage.write(key: "user_phone", value: userData['phone'] ?? "");
  }

  Future<Map<String, String?>> getUserFromLocal() async {
    final name = await _secureStorage.read(key: "user_name");
    final email = await _secureStorage.read(key: "user_email");
    final phone = await _secureStorage.read(key: "user_phone");

    return {
      "firstName": name,
      "email": email,
      "phone": phone,
    };
  }

  Future<void> clearUserFromLocal() async {
    await _secureStorage.delete(key: "user_name");
    await _secureStorage.delete(key: "user_email");
    await _secureStorage.delete(key: "user_phone");
  }
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      // ✅ Allow bypass OTP only for the test account
      if (email == "testuser@example.com" && otp == "999099") {
        print("Bypass OTP accepted for test account $email");
        return true;
      }

      final res = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('Status Code: ${res.statusCode}');
      print('OTP Verify response: ${res.body}');

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['message'] == "correct";
      } else {
        return false;
      }
    } catch (e) {
      print('verifyOtp error: $e');
      return false;
    }
  }
  //
  // Future<bool> verifyOtp(String email, String otp) async {
  //   try {
  //     final res = await http.post(
  //       Uri.parse('$baseUrl/verify-otp'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'email': email,
  //         'otp': otp,
  //       }),
  //     );
  //
  //     print('Status Code: ${res.statusCode}');
  //     print('OTP Verify response: ${res.body}');
  //
  //     if (res.statusCode == 200) {
  //       final json = jsonDecode(res.body);
  //       return json['message'] == "correct";
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     print('verifyOtp error: $e');
  //     return false;
  //   }
  // }
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send reset email');
    } catch (_) {
      throw Exception('Something went wrong');
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final userCred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final sessionId = const Uuid().v4();
    await _firestore.collection('users').doc(userCred.user!.uid).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'session_id': sessionId,
    });
    await _secureStorage.write(key: 'session_id', value: sessionId);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Sign in using Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login failed: No user found.');
      }

      // Step 2: Generate a new session ID
      final sessionId = const Uuid().v4();

      // Step 3: Store session ID in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'session_id': sessionId,
      });

      // Step 4: Store session ID in secure storage
      await _secureStorage.write(key: 'session_id', value: sessionId);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _secureStorage.delete(key: 'session_id');
  }
  Future<String?> checkIfUserExists({required String email, required String phone}) async {
    try {
      final emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        return "Email already exists. Try logging in.";
      }

      final phoneQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        return "Phone number already exists.";
      }

      return null; // No error, user doesn't exist
    } catch (e) {
      return "Failed to check user. Please try again.";
    }
  }
  Future<void> verifyLoginCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseErrorToMessage(e));
    } catch (_) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  String _mapFirebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }
}
