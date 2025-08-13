import 'package:examgrid/routes.dart';
import 'package:examgrid/ui/styles.dart';
import 'package:examgrid/ui/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      //final firstName = _firstNameController.text.trim();
     // final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
     // final password = _passwordController.text.trim();

      context.read<AuthBloc>().add(
            AuthCheckIfUserExists(email: email,phone: phone),
          );
    }
  }

  String? _validateName(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $label';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Enter phone number';
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Phone must be exactly 10 digits';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _obscurePassword = true;
  bool _obsecureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      // appBar: AppBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const LogoLoader(
                message: 'Loading',
              ),
            );
          } else if (state is AuthOtpSent) {
            Navigator.of(context).pop(); // Remove loading
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  phone: _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                  isLoginFlow: false,
                ),
              ),
            );
          } else if (state is AuthError) {
            Navigator.of(context).pop(); // Remove loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 120,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Text(
                    'Create Your Account',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            Container(
              height: 170,
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
                    height: 150,
                    width: 150,
                  ),
                  Text('Please fill in your details to create an Account.'),
                ],
              )),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.white,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: kTextFieldDecoration(
                            context: context, title: 'First Name'),
                        validator: (value) =>
                            _validateName(value, 'first name'),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: kTextFieldDecoration(
                            context: context, title: 'Last Name'),
                        validator: (value) => _validateName(value, 'last name'),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: kTextFieldDecoration(
                            context: context, title: "Mobile Number",prefix: '+91-'),
                        validator: _validatePhone,
                        maxLength: 10,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: kTextFieldDecoration(
                            context: context, title: 'Email'),
                        validator: _validateEmail,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: kTextFieldDecoration(
                          context: context,
                          title: 'Password',
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obsecureConfirmPassword,
                        decoration: kTextFieldDecoration(
                            context: context,
                            title: 'Confirm Password',
                            suffix: IconButton(
                              icon: Icon(
                                _obsecureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obsecureConfirmPassword = !_obsecureConfirmPassword;
                                });
                              },
                            )),
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.login);
                              },
                              child: const Text('Already have an account')),
                          ElevatedButton(
                            onPressed: _onSubmit,
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
