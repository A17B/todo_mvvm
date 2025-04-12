import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'services/task_service.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAomHEBnfIqC5fHaOw6Y8CUgg2TRla9lgQ",
      authDomain: "todomvvm-6d6a0.firebaseapp.com",
      projectId: "todomvvm-6d6a0",
      storageBucket: "todomvvm-6d6a0.appspot.com",
      messagingSenderId: "735770942603",
      appId: "1:735770942603:android:07bd391d344d5f3395888e",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, TaskViewModel?>(
          create: (_) => null,
          update: (_, authViewModel, previousTaskVM) {
            if (authViewModel.user == null) return null;
            final service = TaskService(authViewModel.user!.uid);
            return TaskViewModel(service);
          },
        ),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          return MaterialApp(
            title: 'Shared TODO App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            ),
            home: authViewModel.isLoggedIn
                ? const HomeScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
