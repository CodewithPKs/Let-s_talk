import 'package:flutter/material.dart';
import 'package:lets_talk/Colors/colors.dart';
import 'package:lets_talk/common/custom_button.dart';
import 'package:lets_talk/features/auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    return  Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10,),
            const Text("Welcome to Let'sTalk..",
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: size.height/10),
            Image.asset('images/bg.png',
              height: 400,
              width: 400,
              color: tabColor,
            ),
            SizedBox(height: size.height/9),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text('Read out Privacy Policy. Tap"Agree and continue" to accept the Term',
                style: TextStyle(
                  color: greyColore,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: size.width*0.75,
              child: CustomButton(text: 'AGREE AND CONTINUE', onPressed: () => navigateToLoginScreen(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
