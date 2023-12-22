import 'package:lets_talk/common/enoms/message_enom.dart';

class Message {
  final String senderId;
  final String reciverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessages;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  Message({
    required this.senderId,
    required this.reciverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessageType,
    required this.repliedTo,
    required this.repliedMessages,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'reciverId': reciverId,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessageType' : repliedMessageType.type,
      'repliedTo' : repliedTo,
      'repliedMessages' : repliedMessages,
    };
  }
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      reciverId: map['reciverId'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
        isSeen: map['isSeen'] ?? false,
        repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
        repliedTo : map['repliedTo'] ?? '',
        repliedMessages : map['repliedMessages'] ?? ''
    );
  }

}