import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_provider.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'screens/events_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed (expected if config is placeholder): $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    final router = GoRouter(
      refreshListenable: authService,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminScreen(),
          redirect: (context, state) {
            if (!authService.isAuthenticated) return '/login';
            if (!authService.isAdmin) return '/';
            return null;
          },
        ),
      ],
    );

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'JudgeRules Tracker',
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
        );
      },
    );
  }
}
