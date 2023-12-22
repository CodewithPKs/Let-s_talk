import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/common/Provider/message_reply_provider.dart';
import 'package:lets_talk/features/auth/controller/auth_controller.dart';
import 'package:lets_talk/features/chat/repository/chat_repository.dart';
import 'package:lets_talk/models/message_model.dart';

import '../../../common/enoms/message_enom.dart';
import '../../../models/chat_contact_model.dart';

final ChatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(ChatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContact() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatStream(String reciverUserId) {
    return chatRepository.getChatStream(reciverUserId);
  }

  void sendTextMessage(BuildContext context, String text, String reciverUserId) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.SendTextMessage(
            context: context,
            text: text,
            reciverUserId: reciverUserId,
            senderUser: value!,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendFileMessage(BuildContext context, File file, String reciverUserId, MessageEnum messageEnum,) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendFileMessage(
            context: context,
            file: file,
            recieverUserId: reciverUserId,
            senderUserData: value!,
            ref: ref,
            messageEnum: messageEnum,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGIFMessage(BuildContext context, String gifUrl, reciverUserId) {
    final messageReply = ref.read(messageReplyProvider);
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;

    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newGifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendGIFMessage(
              context: context,
              gifUrl: newGifUrl,
              reciverUserId: reciverUserId,
              senderUser: value!,
              messageReply: messageReply,
            )
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void setChatMessageSeen(BuildContext context, String recieverUserId, String messageId) {
    chatRepository.setChatMessageSeen(context, recieverUserId, messageId);
  }
}
