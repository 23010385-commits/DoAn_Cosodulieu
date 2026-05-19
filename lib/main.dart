import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NgonNgu ngonNguHienTai = NgonNgu.viet;

  void doiNgonNgu(NgonNgu nn) {
    setState(() {
      ngonNguHienTai = nn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFEDE0D4),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7F5539),
          primary: const Color(0xFF7F5539),
          surface: const Color(0xFFE6CCB2),
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF432818)),
          bodyMedium: TextStyle(color: Color(0xFF432818)),
        ),

        cardTheme: const CardThemeData(color: Color(0xFFE6CCB2), elevation: 2),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7F5539),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: LoginScreen(ngonNgu: ngonNguHienTai, doiNgonNgu: doiNgonNgu),
    );
  }
}
