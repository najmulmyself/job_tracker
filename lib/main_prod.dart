import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'firebase_options.dart' as firebase_prod;
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/resume_provider.dart';
import 'providers/theme_provider.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration for PROD
  AppConfig.initialize(AppConfig.prod);

  // Initialize Firebase with PROD configuration
  // Check if Firebase is already initialized to avoid duplicate initialization
  try {
    await Firebase.initializeApp(
      options: firebase_prod.DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase is already initialized, just use the existing instance
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized by google-services.json
      debugPrint('Firebase already initialized, using existing instance');
    } else {
      rethrow;
    }
  }

  // Enable Firestore offline persistence
  final firestoreService = FirestoreService();
  await firestoreService.enableOfflinePersistence();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Pre-load theme settings before app starts
  final themeProvider = await ThemeProvider.create();

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => ResumeProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConfig.instance.appName,
            debugShowCheckedModeBanner: false, // Always false for production
            theme:
                AppTheme.getLightTheme(
                  primaryColor: themeProvider.primaryColor,
                  primaryDarkColor: themeProvider.primaryDarkColor,
                  onPrimaryColor: themeProvider.onPrimaryColor,
                ).copyWith(
                  pageTransitionsTheme: const PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                    },
                  ),
                ),
            darkTheme:
                AppTheme.getDarkTheme(
                  primaryColor: themeProvider.primaryColor,
                  primaryDarkColor: themeProvider.primaryDarkColor,
                  onPrimaryColor: themeProvider.onPrimaryColor,
                ).copyWith(
                  pageTransitionsTheme: const PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                    },
                  ),
                ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
