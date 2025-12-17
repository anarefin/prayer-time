import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/mosque_provider.dart';
import 'providers/prayer_time_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/notification_service.dart';
import 'screens/public/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 
  // Initialize Firebase with auto-generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const PrayerTimeApp());
}

class PrayerTimeApp extends StatelessWidget {
  const PrayerTimeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeAuthListener(),
        ),
        // Mosque Provider
        ChangeNotifierProvider(
          create: (_) => MosqueProvider(),
        ),
        // Prayer Time Provider
        ChangeNotifierProvider(
          create: (_) => PrayerTimeProvider(),
        ),
        // Favorites Provider
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Prayer Time',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: _getHomeScreen(authProvider),
          );
        },
      ),
    );
  }

  Widget _getHomeScreen(AuthProvider authProvider) {
    // Show appropriate screen based on authentication and role
    if (authProvider.isLoggedIn && authProvider.isAdmin) {
      return const AdminDashboardScreen();
    }
    return const HomeScreen();
  }
}
