import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
      },
      theme: ThemeData(
          splashFactory: NoSplash.splashFactory,
          scaffoldBackgroundColor: const Color.fromRGBO(198, 221, 255, 1),
          textTheme: GoogleFonts.abelTextTheme(Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.black, displayColor: Colors.black))),
    ); //placeholder
  }
}
