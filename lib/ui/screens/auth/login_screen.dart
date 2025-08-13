import 'package:examgrid/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';
import '../../../routes.dart';
import '../../widgets/loader.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _error;
//  bool _isLoading = false;

  // void _onLoginPressed() {
  //   final email = _emailController.text.trim();
  //   final password = _passwordController.text;
  //
  //   if (email.isEmpty || password.isEmpty) {
  //     setState(() => _error = 'Please fill in both fields');
  //     return;
  //   }
  //
  //   context.read<AuthBloc>().add(AuthSendOtpRequested(email: email));
  //
  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });
  // }
  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Basic validation
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in both fields');
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email');
      return;
    }

    context.read<AuthBloc>().add(AuthLoginCredentialsChecked(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      // appBar: AppBar(title: const Text("Login")),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {

          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const LogoLoader(message: 'Loading',),
            );
          }

          if (state is AuthError) {
            Navigator.of(context).pop(); // Remove loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }

          if (state is AuthOtpSent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  // not required for login
                  email: state.email,
                  password: _passwordController.text, isLoginFlow: true,
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            const SizedBox(
              height: 150,
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
                    height: 150,
                    width: 150,
                  ),
                 const Text('Please fill in your details to log in to your account.'),
                ],
              )),
            ),
            Expanded(
              child: Container(
                //  padding: EdgeInsets.symmetric(horizontal:20),
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.all(30),
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: kTextFieldDecoration(
                          context: context, title: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: kTextFieldDecoration(context: context, title: 'Password',suffix: IconButton(
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
                    ),),

                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.forgetPass),
                        child: Text('Forget Password?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.signup);
                            },
                            child: const Text('Create an account')),
                        ElevatedButton(
                          onPressed: _onLoginPressed,
                          child: const Text("Login"),
                        ),
                      ],
                    ),
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
