import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'data/repositories/service_locator.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/destination_provider.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/trip_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Service Locator (detects/starts Firebase or activates Mock repositories)
  await locator.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const EzzTripApp(),
    ),
  );
}

class EzzTripApp extends StatelessWidget {
  const EzzTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'EzzTrip',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
