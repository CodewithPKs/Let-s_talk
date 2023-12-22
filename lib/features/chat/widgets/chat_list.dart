import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/Provider/message_reply_provider.dart';
import 'package:lets_talk/common/enoms/message_enom.dart';
import 'package:lets_talk/features/chat/widgets/sender_massage_card.dart';
import 'package:lets_talk/common/widget/loder.dart';
import 'package:lets_talk/features/chat/controller/chat_controller.dart';
import 'package:lets_talk/models/message_model.dart';
import '../../../Information/info.dart';
import 'my_massage_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String reciverUserId;
  const ChatList({
    Key? key,
    required this.reciverUserId
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<ChatList> {

  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref.read(messageReplyProvider.state).update((state) => MessageReply(message, isMe, messageEnum));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: ref.read(ChatControllerProvider).chatStream(widget.reciverUserId),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          SchedulerBinding.instance.addPostFrameCallback((_){
            messageController.jumpTo(messageController.position.maxScrollExtent);
          });

          return ListView.builder(
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];

              if(!messageData.isSeen && messageData.reciverId == FirebaseAuth.instance.currentUser!.uid) {
                ref.read(ChatControllerProvider).setChatMessageSeen(context, widget.reciverUserId, messageData.messageId);
              }
              if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
                return MyMessageCard(
                  message: messageData.text,
                  date: DateFormat.Hm().format(messageData.timeSent),
                  type: messageData.type,
                  username: messageData.repliedTo,
                  onLeftSwipe: () => onMessageSwipe(messageData.text, true, messageData.type),
                  repliedMessageType: messageData.repliedMessageType,
                  repliedText: messageData.repliedMessages,
                  isSeen: messageData.isSeen,
                );
              }
              return SenderMessageCard(
                message: messageData.text,
                date: DateFormat.Hm().format(messageData.timeSent),
                type: messageData.type,
                username: messageData.repliedTo,
                onRightSwipe: () => onMessageSwipe(messageData.text, false, messageData.type),
                repliedMessageType: messageData.repliedMessageType,
                repliedText: messageData.repliedMessages,
              );
            },
          );
        }
    );
  }
}



