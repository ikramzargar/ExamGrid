// import 'dart:async';
//
// import 'package:examgrid/main.dart';
// import 'package:examgrid/routes.dart';
// import 'package:examgrid/ui/widgets/loader.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
//
// import '../../../bloc/auth_bloc/auth_bloc.dart';
// import '../../../bloc/auth_bloc/auth_event.dart';
// import '../../../bloc/auth_bloc/auth_state.dart';
//
// class OtpVerificationScreen extends StatefulWidget {
//   final bool isLoginFlow;
//   final String? firstName;
//   final String? lastName;
//   final String? phone;
//   final String email;
//   final String password;
//
//   const OtpVerificationScreen({
//     super.key,
//     required this.isLoginFlow,
//     this.firstName,
//     this.lastName,
//     this.phone,
//     required this.email,
//     required this.password,
//   });
//
//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }
//
// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   String? _otp;
//
//   Timer? _timer;
//   int _resendCount = 0;
//   int _resendTimer = 10; // Initial 60s, next 120s
//   bool _canResend = false;
//
//   void startResendTimer() {
//     setState(() {
//       _canResend = false;
//     });
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer == 0) {
//         timer.cancel();
//         setState(() {
//           _canResend = _resendCount < 2;
//         });
//       } else {
//         setState(() {
//           _resendTimer--;
//         });
//       }
//     });
//   }
//
//   void handleResendOtp() {
//     if (!_canResend || _resendCount >= 2) return;
//
//     // Increment count
//     _resendCount++;
//
//     // Set next timer duration
//     _resendTimer = _resendCount == 1 ? 20 : 0;
//
//     // Dispatch resend OTP
//     context.read<AuthBloc>().add(
//           AuthSendOtpRequested(
//             email: widget.email, /* counter: _resendCount*/
//           ),
//         );
//
//     // Restart timer if within limits
//     if (_resendCount < 2) {
//       startResendTimer();
//     } else {
//       setState(() => _canResend = false);
//     } // Disable for good after 2nd resend
//   }
//
//   void _onVerifyOtp() {
//     if (_otp == null || _otp!.length != 6) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           const SnackBar(content: Text("Invalid OTP")),
//         );
//       return;
//     }
//
//     context.read<AuthBloc>().add(
//           AuthVerifyOtpRequested(email: widget.email, otp: _otp!),
//         );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     startResendTimer(); // First timer starts with 60s
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthLoading) {
//             showDialog(
//               context: navigatorKey.currentContext!,
//               barrierDismissible: false,
//               builder: (_) => const LogoLoader(message: 'Loading...'),
//             );
//           }
//           if (state is AuthOtpSent) {
//             if (navigatorKey.currentState!.canPop()) {
//               navigatorKey.currentState!.pop(); // Closes loader
//             }
//
//             ScaffoldMessenger.of(navigatorKey.currentContext!)
//               ..hideCurrentSnackBar()
//               ..showSnackBar(
//                 const SnackBar(content: Text('OTP resent successfully')),
//               );
//           }
//           if (state is AuthError) {
//             if (navigatorKey.currentState!.canPop()) {
//               navigatorKey.currentState!.pop(); // Closes loader
//             }
//
//             ScaffoldMessenger.of(navigatorKey.currentContext!)
//               ..hideCurrentSnackBar()
//               ..showSnackBar(
//                 SnackBar(content: Text(state.error)),
//               );
//           }
//           if (state is AuthOtpVerified) {
//             Navigator.of(context, rootNavigator: true).pop(); // Remove loader
//             if (widget.isLoginFlow) {
//               context.read<AuthBloc>().add(
//                     AuthFinalizeLogin(widget.email, widget.password),
//                   );
//             } else {
//               context.read<AuthBloc>().add(
//                     AuthFinalizeSignUp(
//                       firstName: widget.firstName!,
//                       lastName: widget.lastName!,
//                       phone: widget.phone!,
//                       email: widget.email,
//                       password: widget.password,
//                     ),
//                   );
//             }
//           }
//
//           if (state is AuthLoginSuccess || state is AuthSignUpSuccess) {
//             Navigator.of(context, rootNavigator: true).pop(); // Remove loader
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               AppRoutes.home,
//               (route) => false,
//             );
//           }
//         },
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 250,
//               child: Padding(
//                 padding: EdgeInsets.only(top: 20.0),
//                 child: Center(
//                   child: Text(
//                     'Verify your OTP',
//                     style: TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               height: 250,
//               width: MediaQuery.of(context).size.width,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(150),
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Image.asset(
//                     'images/logo.png',
//                     height: 150,
//                     width: 150,
//                   ),
//                   Text('Please enter the OTP sent to ${widget.email}'),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 color: Colors.white,
//                 child: Column(
//                   children: [
//                     OtpTextField(
//                       numberOfFields: 6,
//                       borderColor: Theme.of(context).colorScheme.primary,
//                       showFieldAsBox: true,
//                       onSubmit: (String otp) {
//                         _otp = otp;
//                         _onVerifyOtp();
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     if (_resendCount >= 2)
//                       const Text(
//                         'Maximum resend attempts reached.',
//                         style: TextStyle(color: Colors.grey),
//                       )
//                     else if (_canResend)
//                       TextButton(
//                         onPressed: handleResendOtp,
//                         child: const Text("Resend OTP"),
//                       )
//                     else
//                       Text(
//                         'Resend available in $_resendTimer seconds',
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: _onVerifyOtp,
//                       child: Text(widget.isLoginFlow
//                           ? 'Verify & Login'
//                           : 'Verify & Sign Up'),
//                     ),
//                     const Spacer(),
//                     const Text(
//                       'OTP is valid for 5 minutes.',
//                       style: TextStyle(color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:examgrid/main.dart';
import 'package:examgrid/routes.dart';
import 'package:examgrid/ui/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final bool isLoginFlow;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String email;
  final String password;

  const OtpVerificationScreen({
    super.key,
    required this.isLoginFlow,
    this.firstName,
    this.lastName,
    this.phone,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String? _otp;

  Timer? _timer;
  int _resendCount = 0;
  int _resendTimer = 60; // First wait is 60 seconds
  bool _canResend = false;

  void startResendTimer() {
    setState(() {
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer == 0) {
        timer.cancel();
        setState(() {
          _canResend = _resendCount < 2;
        });
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  void handleResendOtp() {
    if (!_canResend || _resendCount >= 2) return;

    _resendCount++;
    _resendTimer = (_resendCount == 1) ? 120 : 0;

    context.read<AuthBloc>().add(
      AuthReSendOtpRequested(email: widget.email, counter: _resendCount),
    );

    if (_resendCount < 2) {
      startResendTimer();
    } else {
      setState(() => _canResend = false);
    }
  }

  void _onVerifyOtp() {
    if (_otp == null || _otp!.length != 6) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text("Invalid OTP")),
        );
      return;
    }

    context.read<AuthBloc>().add(
      AuthVerifyOtpRequested(email: widget.email, otp: _otp!),
    );
  }

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // if (state is AuthLoading) {
        //   showDialog(
        //     context: navigatorKey.currentContext!,
        //     barrierDismissible: false,
        //     builder: (_) => const LogoLoader(message: 'Loading...'),
        //   );
        // } else {
        //   // Close loader if present
        //   if (navigatorKey.currentState!.canPop()) {
        //     navigatorKey.currentState!.pop();
        //   }
        // }

        if (state is AuthOtpResent) {
          ScaffoldMessenger.of(navigatorKey.currentContext!)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(content: Text('OTP resent successfully')),
            );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(navigatorKey.currentContext!)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(content: Text(state.error)),
            );
        }

        if (state is AuthOtpVerified) {
          if (widget.isLoginFlow) {
            context.read<AuthBloc>().add(
              AuthFinalizeLogin(widget.email, widget.password),
            );
          } else {
            context.read<AuthBloc>().add(
              AuthFinalizeSignUp(
                firstName: widget.firstName!,
                lastName: widget.lastName!,
                phone: widget.phone!,
                email: widget.email,
                password: widget.password,
              ),
            );
          }
        }

        if (state is AuthLoginSuccess || state is AuthSignUpSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
                (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Column(
          children: [
            const SizedBox(
              height: 250,
              child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Text(
                    'Verify your OTP',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 250,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(150),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'images/logo.png',
                    height: 150,
                    width: 150,
                  ),
                  Text('Please enter the OTP sent to ${widget.email}'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    OtpTextField(
                      numberOfFields: 6,
                      borderColor: Theme.of(context).colorScheme.primary,
                      showFieldAsBox: true,
                      onSubmit: (String otp) {
                        _otp = otp;
                        _onVerifyOtp();
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_resendCount >= 2)
                      const Text(
                        'Maximum resend attempts reached.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else if (_canResend)
                      TextButton(
                        onPressed: handleResendOtp,
                        child: const Text("Resend OTP"),
                      )
                    else
                      Text(
                        'Resend available in $_resendTimer seconds',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _onVerifyOtp,
                      child: Text(widget.isLoginFlow
                          ? 'Verify & Login'
                          : 'Verify & Sign Up'),
                    ),
                    const Spacer(),
                    const Text(
                      'OTP is valid for 5 minutes.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}