// lib/services/chat_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/message.dart';

class ChatService {
  // Replace with your server URL
  final String baseUrl = 'http://your-server-ip:port/api';
  
  Future<Message> sendMessage(String message, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
      }),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      return Message(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        text: data['response'] ?? 'No response from server',
        isUser: false,
        timestamp: DateTime.now(),
      );
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
  
  Future<Message> sendMediaMessage(File file, String messageText, String mediaType, String token) async {
    // Create multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/chat/media'),
    );
    
    // Add authorization header
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });
    
    // Add text fields
    request.fields['message'] = messageText;
    
    // Determine media type for the correct MIME type
    MediaType contentType;
    if (mediaType == 'image') {
      contentType = MediaType('image', file.path.split('.').last);
    } else if (mediaType == 'video') {
      contentType = MediaType('video', file.path.split('.').last);
    } else {
      contentType = MediaType('application', 'octet-stream');
    }
    
    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: contentType,
      ),
    );
    
    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      return Message(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        text: data['response'] ?? 'No response from server',
        isUser: false,
        timestamp: DateTime.now(),
      );
    } else {
      throw Exception('Failed to send media: ${response.body}');
    }
  }
  
  Future<List<Message>> getHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/history'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      
      return data.map((msg) => Message(
        id: msg['id'],
        text: msg['text'],
        isUser: msg['isUser'],
        timestamp: DateTime.parse(msg['timestamp']),
        mediaUrl: msg['mediaUrl'],
        mediaType: msg['mediaType'],
      )).toList();
    } else {
      throw Exception('Failed to load chat history: ${response.body}');
    }
  }
}