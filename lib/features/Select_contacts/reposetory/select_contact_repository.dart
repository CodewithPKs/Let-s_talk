import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/features/chat/screens/mobile_chat_screen.dart';
import 'package:lets_talk/common/utils/utils.dart';
import 'package:lets_talk/models/user_model.dart';


final SelectContactRepoProvider = Provider(
        (ref) => SelectContactRepo(
            Firestore: FirebaseFirestore.instance,
        ),
);

class SelectContactRepo{
  final FirebaseFirestore Firestore;

  SelectContactRepo({required this.Firestore});

 Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if(await FlutterContacts.requestPermission()) {
        contacts =  await FlutterContacts.getContacts(withProperties: true);
      }
    } catch(e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async{
   try {
      var userCollection = await Firestore.collection('users').get();
      bool isFound = false;

      for(var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectPhoneNumber = selectedContact.phones[0].number.replaceAll(' ', '');

        if(selectPhoneNumber == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(
              context,
              MobileChatScreen.routeName,
              arguments: {
                'name': userData.name,
                'uid': userData.uid,
              }
          );
        }
      }

      if(!isFound) {
        showSnackBar(context: context, content: 'This number does not exist on this app');
      }
   } catch(e) {
     showSnackBar(context: context, content: e.toString());
   }
  }
}