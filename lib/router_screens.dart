import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lets_talk/features/auth/screens/login_screen.dart';

import 'features/Status/Screens/confirm_status_screen.dart';
import 'features/chat/screens/mobile_chat_screen.dart';
import 'Screens/otp_screens.dart';
import 'common/error.dart';
import 'features/Select_contacts/screens/select_contact_screen.dart';
import 'features/auth/screens/user_information_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch(settings.name) {

    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen(),
      );

    case OtpScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(builder: (context) =>  OtpScreen(verificationId: verificationId,),
      );

    case userInformationScreen.routeName:
      return MaterialPageRoute(builder: (context) => const userInformationScreen(),
      );

    case SelectContactScreen.routeName:
      return MaterialPageRoute(builder: (context) => SelectContactScreen(),
      );


    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      return MaterialPageRoute(
        builder: (context) =>
          MobileChatScreen(
            name: name,
            uid: uid,
          ),
      );

    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(
        builder: (context) =>
            ConfirmStatusScreen(
              file: file,
            ),
      );

    default:
      return MaterialPageRoute(builder: (context) => const Scaffold(
        body: ErrorScreen(error: 'This page doesn\'t exist',),
      ),
      );
  }
}