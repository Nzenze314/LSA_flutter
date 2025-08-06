import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      username: map['username'],
      avatarUrl: map['avatar_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
