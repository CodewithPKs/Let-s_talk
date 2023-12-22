import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/common/Provider/message_reply_provider.dart';
import 'package:lets_talk/common/enoms/message_enom.dart';
import 'package:lets_talk/common/reposetory/common_firebase_storage_reposetory.dart';
import 'package:lets_talk/common/utils/utils.dart';
import 'package:lets_talk/models/chat_contact_model.dart';
import 'package:lets_talk/models/message_model.dart';
import 'package:lets_talk/models/user_model.dart';
import 'package:uuid/uuid.dart';

final ChatRepositoryProvider = Provider(
  (ref) => ChatRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();

        var user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  void _saveDataToContactSubcollection(
    UserModel senderUserData,
    UserModel reciverUserData,
    String text,
    DateTime timeSent,
    String reciverUserId,
  ) async {
    //=============for reciver side===============
    var reciverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(reciverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          reciverChatContact.toMap(),
        );
    //===========for sender side====================
    var senderChatContact = ChatContact(
      name: reciverUserData.name,
      profilePic: reciverUserData.profilePic,
      contactId: reciverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  Stream<List<Message>> getChatStream(String reciverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveMessageToMessageSubcollection({
    required String reciverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String reciverUsername,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String recieverUserName,

  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      reciverId: reciverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessageType: messageReply == null ? MessageEnum.text : messageReply.messageEnum,
      repliedTo: messageReply == null ? '' : messageReply.isMe ? senderUsername : recieverUserName,
      repliedMessages: messageReply == null ? '' : messageReply.message,
    );
    //  users -> senderId -> resiverid -> messages -> messageId -> store Message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
    //  users -> resiverid -> senderId -> messages -> messageId -> store Message
    await firestore
        .collection('users')
        .doc(reciverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void SendTextMessage({
    required BuildContext context,
    required String text,
    required String reciverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,

  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel reciverUserData;

      var userDataMap =
          await firestore.collection('users').doc(reciverUserId).get();
      reciverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactSubcollection(
        senderUser,
        reciverUserData,
        text,
        timeSent,
        reciverUserId,
      );

      _saveMessageToMessageSubcollection(
        reciverUserId: reciverUserId,
        text: text,
        timeSent: DateTime.now(),
        messageId: messageId,
        username: senderUser.name,
        reciverUsername: reciverUserData.name,
        messageType: MessageEnum.text,
        messageReply: messageReply,
        senderUsername: senderUser.name,
        recieverUserName: reciverUserData.name,

      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
        required BuildContext context,
      required File file,
      required String recieverUserId,
      required UserModel senderUserData,
      required ProviderRef ref,
      required MessageEnum messageEnum,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepoProvider)
          .storeFileToFirebase(
          'chats/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
          file
      );

      UserModel? recieverUserData;
      var userDataMap = await firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 photo';
          break;

        case MessageEnum.video:
          contactMsg = '🎥 video';
          break;

        case MessageEnum.audio:
          contactMsg = '🎙️ audio';
          break;

        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }
      _saveDataToContactSubcollection(
          senderUserData,
          recieverUserData,
          contactMsg,
          timeSent,
          recieverUserId
      );

      _saveMessageToMessageSubcollection(
          reciverUserId: recieverUserId,
          text: imageUrl,
          timeSent: timeSent,
          messageId: messageId,
          username: senderUserData.name,
          reciverUsername: recieverUserData.name,
          messageType: messageEnum,
        messageReply: messageReply,
        senderUsername: senderUserData.name,
        recieverUserName: recieverUserData.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String reciverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel reciverUserData;

      var userDataMap =
      await firestore.collection('users').doc(reciverUserId).get();
      reciverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();

      _saveDataToContactSubcollection(
        senderUser,
        reciverUserData,
        'GIF',
        timeSent,
        reciverUserId,
      );

      _saveMessageToMessageSubcollection(
        reciverUserId: reciverUserId,
        text: gifUrl,
        timeSent: DateTime.now(),
        messageId: messageId,
        username: senderUser.name,
        reciverUsername: reciverUserData.name,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
        senderUsername: senderUser.name,
        recieverUserName: reciverUserData.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(BuildContext context, String recieverUserId, String messageId,) async{
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({
             'isSeen' : true
          });
      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({
            'isSeen' : true
           });
    } catch (err) {
      showSnackBar(context: context, content: err.toString());
    }
  }
}
