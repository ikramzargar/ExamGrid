import 'package:examgrid/repositories/auth_repo.dart';
import 'package:examgrid/routes.dart';
import 'package:examgrid/theme/app_theme.dart';
import 'package:examgrid/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_bloc/auth_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc( authRepository: AuthRepository()),
        ),
      ],
      child:  MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.light,
      title: 'Email Auth Demo',
      debugShowCheckedModeBanner: false,
     // home: SplashScreen(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}