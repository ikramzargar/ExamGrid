import 'package:bloc/bloc.dart';

import '../../repositories/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthState()) {
    on<SignUpRequested>(_onSignUp);
    on<EmailLoginRequested>(_onEmailLogin);
    on<VerifyPhoneRequested>(_onVerifyPhone);
    on<OtpSubmitted>(_onOtpSubmit);
    on<LogoutRequested>(_onLogout);
  }

  final AuthRepository _repo;

  Future<void> _onSignUp(SignUpRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repo.signUp(
        firstName: e.firstName,
        lastName: e.lastName,
        phone: e.phone,
        email: e.email,
        password: e.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (err) {
      emit(state.copyWith(status: AuthStatus.error, error: err.toString()));
    }
  }

  Future<void> _onEmailLogin(EmailLoginRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repo.loginWithEmail(email: e.email, password: e.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (err) {
      emit(state.copyWith(status: AuthStatus.error, error: err.toString()));
    }
  }

  Future<void> _onVerifyPhone(VerifyPhoneRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final verificationId = await _repo.startPhoneVerification(e.phone);
      emit(state.copyWith(status: AuthStatus.codeSent, verificationId: verificationId));
    } catch (err) {
      emit(state.copyWith(status: AuthStatus.error, error: err.toString()));
    }
  }

  Future<void> _onOtpSubmit(OtpSubmitted e, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repo.confirmOtp(verificationId: e.verificationId, smsCode: e.smsCode);
      emit(state.copyWith(status: AuthStatus.phoneVerified, user: user));
    } catch (err) {
      emit(state.copyWith(status: AuthStatus.error, error: err.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.initial));
  }
}