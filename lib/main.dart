// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'repositories/auth_repo.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'ui/screens/splash_screen.dart';   // <- your splash

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepository(),
      child: BlocProvider<AuthBloc>(
        create: (ctx) => AuthBloc(ctx.read<AuthRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ExamGrid',
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
          home: const SplashScreen(),           // ⬅ providers already exist here
        ),
      ),
    );
  }
}