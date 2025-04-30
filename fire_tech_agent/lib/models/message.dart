// lib/models/message.dart
class Message {
  final String id;
  final String text;
  final bool isUser; // true if sent by user, false if from agent
  final DateTime timestamp;
  final String? mediaUrl; // For attached media (images, videos, etc.)
  final String? mediaType; // e.g., 'image', 'video', 'document'

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.mediaUrl,
    this.mediaType,
  });
}