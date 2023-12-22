import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/common/utils/utils.dart';
import 'package:lets_talk/features/auth/controller/auth_controller.dart';

class userInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';
  const userInformationScreen({super.key});

  @override
  ConsumerState<userInformationScreen> createState() => _userInformationScreenState();
}

class _userInformationScreenState extends ConsumerState<userInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  File? image;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {

    });
  }

  void storeUserData() async {
    String name = nameController.text.trim();

    if(name.isNotEmpty){
      ref.read(authConterollerProvider)
          .saveUserDataToFirebase(
          context,
          name,
          image,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  image == null ? const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                    ),
                    radius: 64,
                  ) : CircleAvatar(
                    backgroundImage: FileImage(image!),
                    radius: 64,
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                    onPressed: selectImage,
                    icon: Icon(Icons.add_a_photo),
                  ),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width*0.85,
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: storeUserData,
                      icon: const Icon(Icons.done),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

