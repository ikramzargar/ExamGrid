import 'package:examgrid/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/auth_bloc/auth_event.dart';
import '../../bloc/auth_bloc/auth_state.dart';
import 'signUp_screen.dart'; // ← import your new HomePage

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  String? _validEmail(String? v) =>
      v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v) ? null : 'Enter a valid email';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        EmailLoginRequested(_email.text.trim(), _pass.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Login'))),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          // 👉 Navigate to HomePage on successful login
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
              height: 350,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  child: ListView(
                    children: [
                      _buildField(
                        controller: _email,
                        label: 'Email',
                        keyboard: TextInputType.emailAddress,
                        validator: _validEmail,
                      ),
                      _buildField(
                        controller: _pass,
                        label: 'Password',
                        obscure: true,
                        validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Required',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                              );
                            },
                            child: const Text("Don't have an account?"),
                          ),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (ctx, state) => ElevatedButton(
                              onPressed: state.status == AuthStatus.loading ? null : _submit,
                              child: state.status == AuthStatus.loading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const Text('Login'),
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

  // Helper
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboard,
        obscureText: obscure,
        validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }
}