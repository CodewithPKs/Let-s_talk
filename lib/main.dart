
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/Screens/mobile_screen_layout.dart';
import 'package:lets_talk/common/error.dart';
import 'package:lets_talk/features/auth/controller/auth_controller.dart';
import 'package:lets_talk/router_screens.dart';

import 'Colors/colors.dart';
import 'anotherScreens/landing_screen.dart';
import 'common/widget/loder.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
      const ProviderScope(
        child: MyApp(),
      ),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor
        )
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider)
          .when(
        data: (user) {
          if(user == null) {
            return const LandingScreen();
          }
          return const MobileLayoutScreen();
          },
        error: (err, trace) {
            return ErrorScreen(
                error: err.toString(),
            );
          },
        loading: () => Loader(),
      ),
    );
  }
}