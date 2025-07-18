import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/auth_bloc/auth_event.dart';
import '../../bloc/auth_bloc/auth_state.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    _phone.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  // ─────────── Validators
  String? _validEmail(String? v) =>
      v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v) ? null : 'Enter a valid email';
  String? _validPhone(String? v) =>
      v != null && RegExp(r'^\d{10}$').hasMatch(v) ? null : 'Enter 10-digit phone';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignUpRequested(
          firstName: _fname.text.trim(),
          lastName:  _lname.text.trim(),
          phone:     '+91${_phone.text.trim()}',
          email:     _email.text.trim(),
          password:  _pass.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Register'))),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.error ?? 'Auth error')),
            );
          }
        },
        child: Column(
          children: [
            Center(child: Image.asset('images/logo.jpg', height: 200)),
            SizedBox(
              height: 450,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  child: ListView(
                    children: [
                      _buildField(_fname, 'First Name'),
                      _buildField(_lname, 'Last Name'),
                      _buildField(
                        _phone,
                        'Phone (10 digits)',
                        keyboard: TextInputType.phone,
                        validator: _validPhone,
                      ),
                      _buildField(
                        _email,
                        'Email',
                        keyboard: TextInputType.emailAddress,
                        validator: _validEmail,
                      ),
                      _buildField(
                        _pass,
                        'Password',
                        obscure: true,
                        validator: (v) =>
                        v != null && v.length >= 6 ? null : 'Min 6 characters',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text('Already have an account!'),
                          ),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (ctx, state) => ElevatedButton(
                              onPressed:
                              state.status == AuthStatus.loading ? null : _submit,
                              child: state.status == AuthStatus.loading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Text('Sign Up'),
                            ),
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

  // Re-usable field builder
  Widget _buildField(
      TextEditingController ctrl,
      String label, {
        TextInputType keyboard = TextInputType.text,
        bool obscure = false,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboard,
        obscureText: obscure,
        validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }
}