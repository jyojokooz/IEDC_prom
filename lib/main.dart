import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideathon_website/firebase_options.dart';
import 'package:ideathon_website/home_screen.dart';

// --- App-wide Color and Style Constants ---
const kBackgroundColor = Color(0xFF0A041C); // Dark purple-black background
const kPrimaryTextColor = Colors.white;
const kSecondaryTextColor = Colors.white70;

final kPrimaryGradient = LinearGradient(
  colors: [const Color(0xFFE842A0), const Color(0xFFF38565).withOpacity(0.8)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IEDC RIT Ideathon - Prominence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // --- Global Theme Settings ---
        scaffoldBackgroundColor: kBackgroundColor,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: kPrimaryTextColor, displayColor: kPrimaryTextColor),
        // --- TextFormField Theme ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          labelStyle: const TextStyle(color: kSecondaryTextColor),
          hintStyle: const TextStyle(color: kSecondaryTextColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE842A0)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
