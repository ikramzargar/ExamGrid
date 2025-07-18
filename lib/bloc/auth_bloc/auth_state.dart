import 'package:equatable/equatable.dart';

import '../../models/user_model.dart';

/// Status values drive UI reactions
/// --------------------------------
/// * `initial`        – idle
/// * `loading`        – API call in progress
/// * `codeSent`       – Firebase has sent OTP SMS
/// * `phoneVerified`  – OTP accepted, phone linked (pre-payment)
/// * `authenticated`  – user fully logged in after sign-up/login (may still need phoneVerified)
/// * `error`          – something failed, see `error` string
enum AuthStatus {
  initial,
  loading,
  codeSent,
  phoneVerified,
  authenticated,
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.verificationId,
    this.error,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? verificationId;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? verificationId,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      verificationId: verificationId ?? this.verificationId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, user, verificationId, error];
}