import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthAuthenticated extends AuthEvent{
}
// Send OTP
class AuthSendOtpRequested extends AuthEvent {
  final String email;


  const AuthSendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
//Resend OTP
class AuthReSendOtpRequested extends AuthEvent {
  final String email;
    final int counter;


  const AuthReSendOtpRequested({required this.email, required this.counter});

  @override
  List<Object?> get props => [email];
}


// 🔹 OTP Verification
class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyOtpRequested( {required this.otp, required this.email});

  @override
  List<Object?> get props => [otp , email];
}

// 🔹 Finalize Firebase user creation after OTP
class AuthFinalizeSignUp extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;

  const AuthFinalizeSignUp({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, email, password];
}

// 🔹 Finalize login after OTP
class AuthFinalizeLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthFinalizeLogin(this.email,this.password);

  @override
  List<Object?> get props => [email,password];
}
class AuthCheckIfUserExists extends AuthEvent {
  final String email;
  final String phone;

  const AuthCheckIfUserExists({required this.email, required this.phone});
}
class AuthLoginCredentialsChecked extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginCredentialsChecked({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSendResetLinkRequested extends AuthEvent {
  final String email;
  const AuthSendResetLinkRequested(this.email);
  @override
  List<Object?> get props => [email];
}
// 🔹 Logout
class AuthLogoutRequested extends AuthEvent {}