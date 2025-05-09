// lib/screens/chat_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAttachmentMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).user?.token ?? '';
      if (token.isNotEmpty) {
        Provider.of<ChatProvider>(context, listen: false).loadChatHistory(token);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final token = Provider.of<AuthProvider>(context, listen: false).user?.token ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in')),
      );
      return;
    }

    _messageController.clear();
    
    try {
      await Provider.of<ChatProvider>(context, listen: false).sendMessage(text, token);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop(); // Close the attachment menu
    setState(() {
      _isAttachmentMenuOpen = false;
    });
    
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      _sendMediaFile(File(pickedFile.path), 'image');
    }
  }

  Future<void> _pickVideo() async {
    Navigator.of(context).pop(); // Close the attachment menu
    setState(() {
      _isAttachmentMenuOpen = false;
    });
    
    final pickedFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendMediaFile(File(pickedFile.path), 'video');
    }
  }

  Future<void> _pickAudio() async {
    Navigator.of(context).pop(); // Close the attachment menu
    setState(() {
      _isAttachmentMenuOpen = false;
    });
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    
    if (result != null) {
      File file = File(result.files.single.path!);
      _sendMediaFile(file, 'audio');
    }
  }

  Future<void> _pickDocument() async {
    Navigator.of(context).pop(); // Close the attachment menu
    setState(() {
      _isAttachmentMenuOpen = false;
    });
    
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      _sendMediaFile(file, 'document');
    }
  }

  Future<void> _sendMediaFile(File file, String mediaType) async {
    final token = Provider.of<AuthProvider>(context, listen: false).user?.token ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in')),
      );
      return;
    }
    
    final text = _messageController.text.trim();
    _messageController.clear();
    
    try {
      await Provider.of<ChatProvider>(context, listen: false)
          .sendMediaMessage(file, text, mediaType, token);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showAttachmentMenu() {
    setState(() {
      _isAttachmentMenuOpen = true;
    });
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Select Image'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Select Video'),
              onTap: _pickVideo,
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Select Audio File'),
              onTap: _pickAudio,
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Upload Document'),
              onTap: _pickDocument,
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        _isAttachmentMenuOpen = false;
      });
    });
  }

  Future<void> _startLiveVideo() async {
    // If menu is open, close it
    if (_isAttachmentMenuOpen) {
      Navigator.of(context).pop();
      setState(() {
        _isAttachmentMenuOpen = false;
      });
    }
    
    // For testing purposes, simply send a message
    final token = Provider.of<AuthProvider>(context, listen: false).user?.token ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in')),
      );
      return;
    }
    
    try {
      await Provider.of<ChatProvider>(context, listen: false).sendMessage(
        "Live video feature will be implemented soon.",
        token
      );
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null) ...[
              _buildMediaPreview(message),
              const SizedBox(height: 8),
            ],
            Text(
              message.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(Message message) {
    switch (message.mediaType) {
      case 'image':
        return message.mediaUrl!.startsWith('http')
            ? Image.network(
                message.mediaUrl!,
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              )
            : Image.file(
                File(message.mediaUrl!),
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              );
      case 'video':
        return Container(
          height: 150,
          width: double.infinity,
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 50,
            ),
          ),
        );
      case 'audio':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.audiotrack, color: Colors.blue[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.mediaUrl!.split('/').last,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Audio File',
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_arrow, color: Colors.blue[800]),
            ],
          ),
        );
      case 'document':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.mediaUrl!.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = Provider.of<ChatProvider>(context).messages;
    final isTyping = Provider.of<ChatProvider>(context).isTyping;
    
    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Tech Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Provider.of<ChatProvider>(context).isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (ctx, index) {
                      if (index == messages.length && isTyping) {
                        // Typing indicator
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Typing'),
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return _buildMessageBubble(messages[index]);
                    },
                  ),
          ),
          
          // Message input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _isAttachmentMenuOpen ? null : _showAttachmentMenu,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                // Add video call button here
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: _startLiveVideo,
                  color: Colors.blue,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}