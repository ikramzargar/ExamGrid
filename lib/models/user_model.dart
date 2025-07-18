import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.isPaid,
    required this.isPhoneVerified,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final bool isPaid;
  final bool isPhoneVerified;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      isPaid: data['isPaid'] ?? false,
      isPhoneVerified: data['isPhoneVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'isPaid': isPaid,
    'isPhoneVerified': isPhoneVerified,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}