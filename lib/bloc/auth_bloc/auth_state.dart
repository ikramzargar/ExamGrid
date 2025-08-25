import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 🔹 Initial State
class AuthInitial extends AuthState {}
class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> userData;

  const AuthAuthenticated({required this.userData});

  @override
  List<Object?> get props => [userData];
}
// 🔹 Loading
class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}

// 🔹 OTP Sent
class AuthOtpSent extends AuthState {
  final String email;

  const AuthOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

// 🔹 OTP Verification States
class AuthOtpVerified extends AuthState {}

class AuthOtpVerificationFailed extends AuthState {
  final String error;

  const AuthOtpVerificationFailed(this.error);

  @override
  List<Object?> get props => [error];
}

// 🔹 Finalization States (Signup & Login)
class AuthSignUpSuccess extends AuthState {}
class AuthOtpResent extends AuthState {}
class AuthOtpLimit extends AuthState {}

class AuthSignUpFailure extends AuthState {
  final String error;

  const AuthSignUpFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthLoginSuccess extends AuthState {}

class AuthLoginFailure extends AuthState {
  final String error;

  const AuthLoginFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthResetLinkSent extends AuthState {}

// 🔹 Logout State
class AuthLoggedOut extends AuthState {}
