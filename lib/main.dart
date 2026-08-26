import 'package:flutter/material.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';
import 'package:wovzo_mobile/core/di/injection.dart';

void main() {
  setupInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wovzo Store',
      routerConfig: appRouter,
    );
  }
}
