import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/Colors/colors.dart';
import 'package:lets_talk/common/custom_button.dart';
import 'package:lets_talk/common/utils/utils.dart';
import 'package:lets_talk/features/auth/controller/auth_controller.dart';


class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country _country) {
          setState(() {
            country = _country;
          });
        });
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if(country!= null && phoneNumber.isNotEmpty) {
      ref
          .read(authConterollerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      showSnackBar(context: context, content: 'Fill out the all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Enter your phone number"),
          elevation: 0,
          backgroundColor: backgroundColor,
        ),
        body: Padding(
          padding: EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Let\'sTalk will need to verify your phone number.'),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: pickCountry,
                  child: const Text('Pick Country'),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    if (country != null) Text('+${country!.phoneCode}'),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: size.width * 0.7,
                      child: TextField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(hintText: 'phone number'),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.6,
                ),
                SizedBox(
                  width: 90,
                  child: CustomButton(
                    onPressed: sendPhoneNumber,
                    text: 'NEXT',
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
