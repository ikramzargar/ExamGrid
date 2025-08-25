import 'package:examgrid/ui/screens/auth/forget_password_screen.dart';
import 'package:examgrid/ui/screens/dashboard.dart';
import 'package:examgrid/ui/screens/test/test_history.dart';
import 'package:flutter/material.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/home_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String forgetPass = '/forgetPass';
  static const String homeScreen = '/homeScreen';
  static const String testHistory = '/testHistory';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case testHistory:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      case homeScreen:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case forgetPass:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // case otp:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   if (args == null || !args.containsKey('email')) {
      //     return _errorRoute();
      //   }
        // return MaterialPageRoute(
        //   builder: (_) => OtpScreen(email: args['email']),
        // );

      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('404 | Page not found'),
        ),
      ),
    );
  }
}