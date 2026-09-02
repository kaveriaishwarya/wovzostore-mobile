import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wovzo_mobile/core/di/injection.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI Infrastructure
  setupInjection();

  // Restore session foundation
  final authCubit = sl<AuthCubit>();
  authCubit.restoreSession();

  runApp(MyApp(authCubit: authCubit));
}

class MyApp extends StatefulWidget {
  final AuthCubit? authCubit;

  const MyApp({super.key, this.authCubit});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit? _activeCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _activeCubit = widget.authCubit ?? (sl.isRegistered<AuthCubit>() ? sl<AuthCubit>() : null);
    _router = AppRouter.createRouter(authCubit: _activeCubit);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCubit == null) {
      return MaterialApp.router(
        title: 'Wovzo Store',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      );
    }

    return BlocProvider<AuthCubit>.value(
      value: _activeCubit!,
      child: MaterialApp.router(
        title: 'Wovzo Store',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
