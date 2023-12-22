import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/common/widget/loder.dart';
import 'package:lets_talk/features/auth/controller/auth_controller.dart';

import '../../../Colors/colors.dart';
import '../widgets/chat_list.dart';
import '../../../models/user_model.dart';
import '../widgets/bottom_chat_feild.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  const MobileChatScreen({Key? key, required this.name, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: StreamBuilder<UserModel>(
          stream: ref.read(authConterollerProvider).userDataById(uid),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            return Column(
              children: [
                Text(name),
                Text(snapshot.data!.isOnline ? 'online' : 'offline',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
          children: [
          Expanded(
            child: ChatList(reciverUserId: uid,),
          ),
          BottomChatField(
            reciverUserId: uid,
          ),
        ],
      ),
    );
  }
}


