import 'package:bloc/bloc.dart';
import '../../repositories/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthReSendOtpRequested>(_onReSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthFinalizeSignUp>(_onFinalizeSignUp);
    on<AuthFinalizeLogin>(_onFinalizeLogin);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSendResetLinkRequested>(_onSendResetLink);
    on<AuthCheckIfUserExists>(_onCheckIfUserExists);
    on<AuthLoginCredentialsChecked>(_onCheckUserCredentials);
  }

  Future<void> _onSendOtpRequested(AuthSendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.sendOtp(event.email);
      emit(AuthOtpSent(event.email));
    } catch (e) {
      emit(AuthError('Failed to send OTP: $e'));
    }
  }
  Future<void> _onReSendOtpRequested(
      AuthReSendOtpRequested event, Emitter<AuthState> emit) async {
     //emit(AuthLoading());
    try {
      await authRepository.sendOtp(event.email); // Call your API
      emit(AuthOtpResent()); // Success state
    } catch (e) {
      emit(AuthError('Failed to send OTP: $e')); // Error state
    }
  }

  Future<void> _onVerifyOtpRequested(AuthVerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isValid = await authRepository.verifyOtp(event.email, event.otp);
      if (isValid) {
        emit(AuthOtpVerified());
      } else {
        emit(const AuthError('Invalid OTP'));
      }
    } catch (e) {
    //  emit(AuthError('OTP verification failed: $e'));
    }
  }
  Future<void> _onCheckIfUserExists(AuthCheckIfUserExists event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final errorMessage = await authRepository.checkIfUserExists(
      email: event.email,
      phone: event.phone,
    );

    if (errorMessage != null) {
      emit(AuthError(errorMessage));
    } else {
      // No user found → proceed to send OTP
      add(AuthSendOtpRequested(email: event.email));
    }
  }
  Future<void> _onFinalizeSignUp(AuthFinalizeSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.createUser(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,

      );
      emit(AuthSignUpSuccess());
    } catch (e) {
      emit(AuthSignUpFailure('Sign-up failed: $e'));
    }
  }

  Future<void> _onFinalizeLogin(AuthFinalizeLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.login(email: event.email,password: event.password);
      emit(AuthLoginSuccess());
    } catch (e) {
      emit(AuthLoginFailure('Login failed: $e'));
    }
  }
  Future<void> _onCheckUserCredentials(AuthLoginCredentialsChecked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.verifyLoginCredentials(
        email: event.email,
        password: event.password,
      );

      // If login successful, proceed to OTP
      add(AuthSendOtpRequested(email: event.email));
    } catch (e) {
    emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }

  }


  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthInitial());
  }
  Future<void> _onSendResetLink(
      AuthSendResetLinkRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      await authRepository.sendPasswordResetEmail(event.email);
      emit(AuthResetLinkSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}