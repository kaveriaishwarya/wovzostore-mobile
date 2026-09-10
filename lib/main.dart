import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wovzo_mobile/core/di/injection.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_cubit.dart';

import 'package:wovzo_mobile/features/customer_onboarding/presentation/bloc/customer_onboarding_cubit.dart';

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
  late final StoreContextCubit? _storeContextCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _activeCubit = widget.authCubit ?? (sl.isRegistered<AuthCubit>() ? sl<AuthCubit>() : null);
    _storeContextCubit = sl.isRegistered<StoreContextCubit>() ? sl<StoreContextCubit>() : null;
    _router = AppRouter.createRouter(authCubit: _activeCubit, storeContextCubit: _storeContextCubit);
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _activeCubit!),
        if (_storeContextCubit != null)
          BlocProvider<StoreContextCubit>.value(value: _storeContextCubit!),
        if (sl.isRegistered<CustomerOnboardingCubit>())
          BlocProvider<CustomerOnboardingCubit>(create: (_) => sl<CustomerOnboardingCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Wovzo Store',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
