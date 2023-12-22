import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/common/Provider/message_reply_provider.dart';
import 'package:lets_talk/common/enoms/message_enom.dart';
import 'package:lets_talk/common/utils/utils.dart';
import 'package:lets_talk/features/chat/controller/chat_controller.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:lets_talk/features/chat/widgets/message_reply_preview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../Colors/colors.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String reciverUserId;
  const BottomChatField({
    Key? key,
    required this.reciverUserId,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecoder;
  bool isRecorderInit = false;
  bool isRecording = false;
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _soundRecoder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
   final status = await Permission.microphone.request();
   if (status != PermissionStatus.granted) {
     throw RecordingPermissionException("Mic permission is not allowed!");
   }
   await _soundRecoder!.openRecorder();
   isRecorderInit = true;
  }

  void sendTextmessage() async {
    if (isSendButton) {
      ref.read(ChatControllerProvider).sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.reciverUserId,
          );
      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';

      if(!isRecorderInit){
        return;
      }

      if(isRecording) {
        await _soundRecoder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecoder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });

    }
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ref
        .read(ChatControllerProvider)
        .sendFileMessage(context, file, widget.reciverUserId, messageEnum);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectGIF() async {
    final gif = await pickGIF(context);
    if (gif != null) {
      ref.read(ChatControllerProvider).sendGIFMessage(context, gif.url, widget.reciverUserId);
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyBoard() => focusNode.requestFocus();
  void hideKeyBoard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if(isShowEmojiContainer) {
      showKeyBoard();
      hideEmojiContainer();
    } else {
      hideKeyBoard();
      showEmojiContainer();
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
    _soundRecoder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                controller: _messageController,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      isSendButton = true;
                    });
                  } else {
                    setState(() {
                      isSendButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: toggleEmojiKeyboardContainer,
                              icon: const Icon(
                                Icons.emoji_emotions,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              onPressed: selectGIF,
                              icon: const Icon(
                                Icons.gif,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        )),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: selectVideo,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 2, left: 2),
              child: CircleAvatar(
                  backgroundColor: const Color(0xff128c7e),
                  radius: 25,
                  child: GestureDetector(
                    onTap: sendTextmessage,
                    child: Icon(
                      isSendButton ? Icons.send : isRecording ? Icons.close : Icons.mic,
                      color: Colors.white,
                    ),
                  )),
            ),
          ],
        ),
        isShowEmojiContainer ? SizedBox(
          height: 310,
          child: EmojiPicker(
            onEmojiSelected: ((category, emoji) {
              setState(() {
                _messageController.text = _messageController.text+emoji.emoji;
              });
              if(!isSendButton) {
                setState(() {
                  isSendButton = true;
                });
              }
            }),
          ),
        ) : const SizedBox()
      ],
    );
  }
}
