// lib/providers/chat_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false; // For typing indicator
  final ChatService _chatService = ChatService();
  
  List<Message> get messages => [..._messages];
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  
  // Initialize chat history
  Future<void> loadChatHistory(String token) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Comment this out for testing
      // _messages = await _chatService.getHistory(token);
      
      // Use this for testing instead
      _messages = [
        Message(
          id: '1',
          text: 'Hello! How can I help you today?',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Message(
          id: '2',
          text: 'I need help with a fire alarm installation.',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        Message(
          id: '3',
          text: 'Sure, I can help with that. What type of system are you working with?',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading chat history: $e');
    }
  }
  
  // Send a text message
  Future<void> sendMessage(String text, String token) async {
    if (text.isEmpty) return;
    
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();
    
    try {
      // Comment this out for testing
      // final agentResponse = await _chatService.sendMessage(text, token);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Use this for testing instead
      final agentResponse = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'This is a test response to: "$text"',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _isTyping = false;
      _messages.add(agentResponse);
      notifyListeners();
    } catch (e) {
      _isTyping = false;
      notifyListeners();
      print('Error sending message: $e');
      rethrow;
    }
  }
  
  // Send a media message
  Future<void> sendMediaMessage(File file, String text, String mediaType, String token) async {
    // Create a placeholder message to show immediately
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.isEmpty ? 'Sent ${mediaType}' : text,
      isUser: true,
      timestamp: DateTime.now(),
      mediaUrl: file.path,
      mediaType: mediaType,
    );
    
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();
    
    try {
      // Comment this out for testing
      // final agentResponse = await _chatService.sendMediaMessage(file, text, mediaType, token);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Use this for testing instead
      final agentResponse = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'I received your ${mediaType}. Is there anything specific you want me to analyze from it?',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _isTyping = false;
      _messages.add(agentResponse);
      notifyListeners();
    } catch (e) {
      _isTyping = false;
      notifyListeners();
      print('Error sending media: $e');
      rethrow;
    }
  }
  
  // Clear chat history (locally)
  void clearChat() {
    _messages = [];
    notifyListeners();
  }
}