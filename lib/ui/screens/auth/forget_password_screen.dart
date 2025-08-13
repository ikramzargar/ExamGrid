import 'package:examgrid/bloc/auth_bloc/auth_bloc.dart';
import 'package:examgrid/bloc/auth_bloc/auth_event.dart';
import 'package:examgrid/bloc/auth_bloc/auth_state.dart';
import 'package:examgrid/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitEmail() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      context.read<AuthBloc>().add(AuthSendResetLinkRequested(email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.primary,
     // appBar: AppBar(title: const Text("Reset Password")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthResetLinkSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset link sent!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // return Column(
          //  // mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     const SizedBox(
          //       height: 250,
          //       child: Padding(
          //         padding: const EdgeInsets.only(top: 20.0),
          //         child: Center(
          //           child: Text(
          //             'Create Your Account',
          //             style: TextStyle(
          //                 fontSize: 30,
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.white),
          //           ),
          //         ),
          //       ),
          //     ),
          //     Container(
          //       height: 200,
          //       width: MediaQuery.of(context).size.width,
          //       decoration: const BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.only(
          //           topLeft: Radius.circular(150),
          //         ),
          //       ),
          //       child: Center(
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.end,
          //             children: [
          //               Image.asset(
          //                 'images/logo.png',
          //                 height: 150,
          //                 width: 150,
          //               ),
          //               Text('Please fill in your details to log in to your account.'),
          //             ],
          //           )),
          //     ),
          //     Container(
          //       color: Colors.white,
          //       child: Expanded(
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.end,
          //           children: [
          //             const SizedBox(height: 24),
          //             Form(
          //               key: _formKey,
          //               child: Padding(
          //                 padding: const EdgeInsets.all(18.0),
          //                 child: TextFormField(
          //                   controller: _emailController,
          //                   decoration: kTextFieldDecoration(context: context, title: 'Email'),
          //                   keyboardType: TextInputType.emailAddress,
          //                   validator: (value) {
          //                     if (value == null || value.trim().isEmpty) {
          //                       return "Please enter your email";
          //                     }
          //                     if (!value.contains('@') || !value.contains('.')) {
          //                       return "Enter a valid email";
          //                     }
          //                     return null;
          //                   },
          //                 ),
          //               ),
          //             ),
          //             const SizedBox(height: 24),
          //             state is AuthLoading
          //                 ? const CircularProgressIndicator()
          //                 : SizedBox(
          //               width: double.infinity,
          //               child: ElevatedButton(
          //                 onPressed: _submitEmail,
          //                 child: const Text("Send Reset Email"),
          //               ),
          //             ),
          //           //  SizedBox(height: MediaQuery.of(context).size.height/2-100,),
          //           ],
          //         ),
          //       ),
          //     ),
          //
          //   ],
          // );
          return  SizedBox.expand(
            child: Column(
              children: [
                // Top Header
                const SizedBox(
                  height: 250,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text(
                        'Reset Your Password',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo Section
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(150),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          'images/logo.png',
                          height: 120,
                          width: 120,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your email to reset your password.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom section (fills remaining space)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: kTextFieldDecoration(context: context, title: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your email";
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                         TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancel')),
                         ElevatedButton(
                           onPressed: _submitEmail,
                           child: const Text("Send Reset Email"),
                         ),
                       ],),

                        const Spacer(), // pushes everything up
                        const Text(
                          'You will receive a reset link if your account exists.',
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
          );
        },
      ),
    );
  }
}