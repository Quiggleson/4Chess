import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
      },
      theme: ThemeData(
          useMaterial3: true,
          splashFactory: NoSplash.splashFactory,
          scaffoldBackgroundColor: const Color.fromRGBO(198, 221, 255, 1),
          textTheme: GoogleFonts.abelTextTheme(Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.black, displayColor: Colors.black))),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
