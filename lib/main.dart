import 'package:flutter/material.dart';
import 'package:wovzo_mobile/core/di/injection.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Core DI Infrastructure
  setupInjection();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wovzo Store',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.createRouter(),
    );
  }
}
