import 'package:equatable/equatable.dart';

/// Events that drive the AuthBloc.
///
/// Flow we support now:
///   1⃣  Email + Password sign-up/login
///   2⃣  Later, user verifies phone via Firebase SMS OTP before payment
///
/// * PhoneLoginRequested has been removed (not needed in current flow)
/// * Added VerifyPhoneRequested → triggers send-OTP
/// * OtpSubmitted remains to confirm the OTP
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// ────────────────────────────────────────────────────────────── Sign-Up
class SignUpRequested extends AuthEvent {
  const SignUpRequested({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
  });
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;

  @override
  List<Object?> get props => [firstName, lastName, phone, email, password];
}

// ─────────────────────────────────────────────────────────── Email Login
class EmailLoginRequested extends AuthEvent {
  const EmailLoginRequested(this.email, this.password);
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

// ─────────────────────────────────────────── Phone Verification (OTP)
/// Sends an OTP to the given phone (must include country code e.g. +91…).
class VerifyPhoneRequested extends AuthEvent {
  const VerifyPhoneRequested(this.phone);
  final String phone;
  @override
  List<Object?> get props => [phone];
}

/// Confirms the OTP that the user typed in.
class OtpSubmitted extends AuthEvent {
  const OtpSubmitted(this.verificationId, this.smsCode);
  final String verificationId;
  final String smsCode;
  @override
  List<Object?> get props => [verificationId, smsCode];
}

// ───────────────────────────────────────────────────────────── Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}