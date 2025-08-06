import 'package:supabase_flutter/supabase_flutter.dart';

class Conversation {
  final String id;
  final String userId;
  final DateTime time;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.time,
    required this.createdAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      userId: map['sender'],
      time: DateTime.parse(map['time']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'time': time.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
