import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';


/// Handles every interaction with FirebaseAuth / Firestore for ExamGrid
/// Flow:
///   • Users initially sign-up with EMAIL + PASSWORD  ➜ phone is stored but **not verified**
///   • After login, user must verify phone (OTP) *before* payment.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _fs = firestore ?? FirebaseFirestore.instance,
        _secure = secureStorage ?? const FlutterSecureStorage();

  // ─────────────────────────────────────────────────────────────────— Fields
  final FirebaseAuth _auth;
  final FirebaseFirestore _fs;
  final FlutterSecureStorage _secure;
  static const _uuid = Uuid();

  // ───────────────────────────────────────────────────────────── Sign-Up ↓↓↓
  Future<AppUser> signUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final sessionId = _uuid.v4();
    await _secure.write(key: 'sessionId', value: sessionId);

    final userRef = _fs.collection('users').doc(cred.user!.uid);
    await userRef.set({
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'isPaid': false,
      'isPhoneVerified': false,
      'sessionId': sessionId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return AppUser(
      uid: cred.user!.uid,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      isPaid: false,
      isPhoneVerified: false,
    );
  }

  // ───────────────────────────────────────────────────────────── Email Login
  Future<AppUser> loginWithEmail({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _refreshSession(cred.user!);
  }

  // ───────────────────────────────────────────────────── Phone Verification
  /// Send OTP to the given phone (string must include country code, e.g. "+91…")
  Future<String> startPhoneVerification(String phone) async {
    final completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      codeSent: (id, _) => completer.complete(id),
      verificationFailed: completer.completeError,
      verificationCompleted: (cred) async {
        // Auto-retrieval path → instantly link phone.
        await _linkPhoneCredential(cred);
        completer.complete('AUTO');
      },
      codeAutoRetrievalTimeout: (id) => completer.complete(id),
    );
    return completer.future;
  }

  /// Confirm the OTP and link the phone credential to the existing user.
  Future<AppUser> confirmOtp({required String verificationId, required String smsCode}) async {
    final cred = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    await _linkPhoneCredential(cred);
    return _getCurrentUserModel();
  }

  Future<void> _linkPhoneCredential(AuthCredential cred) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'not-logged-in', message: 'No logged in user');

    // If this phone is not already linked, link it.
    try {
      await user.linkWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' || e.code == 'credential-already-in-use') {
        // Ignore – phone already linked.
      } else {
        rethrow;
      }
    }

    // Mark verified in Firestore
    await _fs.collection('users').doc(user.uid).set({
      'isPhoneVerified': true,
    }, SetOptions(merge: true));
  }

  // ───────────────────────────────────────────────────────────── Sign-Out
  Future<void> signOut() async {
    await _secure.delete(key: 'sessionId');
    await _auth.signOut();
  }

  // ───────────────────────────────────────────────────── Helpers & Session
  Future<AppUser> _refreshSession(User user) async {
    final sid = _uuid.v4();
    await _secure.write(key: 'sessionId', value: sid);
    await _fs.collection('users').doc(user.uid).set({'sessionId': sid}, SetOptions(merge: true));
    return _getCurrentUserModel();
  }

  Future<AppUser> _getCurrentUserModel() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _fs.collection('users').doc(uid).get();
    return AppUser.fromFirestore(doc);
  }
}
