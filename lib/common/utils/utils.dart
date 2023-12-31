import 'dart:io';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content)
      )
  );
}

Future<File?>  pickImageFromGallery(BuildContext context) async {
  File? image;
  try{
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch(e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?>  pickVideoFromGallery(BuildContext context) async {
  File? video;
  try{
    final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if(pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch(e) {
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  GiphyGif? gif;
  try{
    gif = await Giphy.getGif(
        context: context,
        apiKey: 'DYSbAC90XxRpZlhgdw1dLNkTxP99GLTV',
    );
  } catch (err){
    showSnackBar(context: context, content: err.toString());
  }
  return gif;
}