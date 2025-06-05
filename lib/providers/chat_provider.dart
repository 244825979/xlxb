import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/storage_service.dart';
import '../services/deepseek_service.dart';
import '../utils/mock_data.dart';

class ChatProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final DeepseekService _deepseekService = DeepseekService();

  // 状态变量
  bool _isLoading = false;
  bool _isTyping = false;
  List<ChatMessage> _messages = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  List<ChatMessage> get messages => _messages;

  // 初始化聊天数据
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 初始化存储服务
      await _storageService.initialize();

      // 加载聊天消息
      await _loadMessages();

      // 如果没有消息，添加欢迎消息
      if (_messages.isEmpty) {
        final welcomeMessage = ChatMessage.aiReply(
          content: '您好！我是您的心声助手。准备好记录您的心声了吗？',
        );
        _messages.add(welcomeMessage);
        await _storageService.addChatMessage(welcomeMessage);
      }

    } catch (e) {
      print('聊天初始化失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载聊天消息
  Future<void> _loadMessages() async {
    try {
      _messages = await _storageService.getChatMessages();
      
      // 按时间排序，最新的在后面
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
    } catch (e) {
      print('加载聊天消息失败: $e');
      _messages = [];
    }
  }

  // 发送文本消息
  Future<void> sendTextMessage(String text) async {
    if (text.isEmpty) return;

    final message = ChatMessage.userText(content: text);
    _messages.add(message);
    notifyListeners();

    // 保存用户消息
    await _storageService.addChatMessage(message);

    // 获取AI回复
    await _getAiResponse(text);
  }

  // 获取AI回复
  Future<void> _getAiResponse(String userMessage) async {
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _deepseekService.getChatResponse(userMessage);
      
      final aiMessage = ChatMessage.aiReply(content: response);
      _messages.add(aiMessage);
      
      // 保存AI消息
      await _storageService.addChatMessage(aiMessage);
    } catch (e) {
      print('AI回复失败: $e');
      
      // 添加错误消息
      final errorMessage = ChatMessage.aiReply(
        content: '抱歉，我现在遇到了一些问题。请稍后再试。',
      );
      _messages.add(errorMessage);
      await _storageService.addChatMessage(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // 清除聊天记录
  Future<void> clearMessages() async {
    try {
      _messages.clear();
      await _storageService.saveChatMessages(_messages);
      
      // 添加初始欢迎消息
      final welcomeMessage = ChatMessage.aiReply(
        content: '您好！我是您的心声助手。准备好记录您的心声了吗？',
      );
      
      _messages.add(welcomeMessage);
      await _storageService.addChatMessage(welcomeMessage);
      
      notifyListeners();
    } catch (e) {
      print('清除聊天记录失败: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
} 