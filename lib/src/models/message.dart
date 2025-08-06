import 'package:supabase_flutter/supabase_flutter.dart';

class Message {
  final String conversationId;
  final String sender;
  final String content;
  final DateTime time;

  Message({
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.time,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      conversationId: map['convo_id'],
      sender: map['sender'],
      content: map['content'],
      time: DateTime.parse(map['time'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'convo_id': conversationId,
      'sender': sender,
      'content': content,
      'time': time.toIso8601String()
    };
  }
}
