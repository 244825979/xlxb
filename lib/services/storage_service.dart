import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voice_record.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';
import '../models/mood_data.dart';
import '../models/comment.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // 存储键名常量
  static const String _keyVoiceRecords = 'voice_records';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyPlazaPosts = 'plaza_posts';
  static const String _keyChatMessages = 'chat_messages';
  static const String _keyMoodData = 'mood_data';
  static const String _keyAppSettings = 'app_settings';
  static const String _keyLastOpenDate = 'last_open_date';
  static const String _keyDailyQuote = 'daily_quote';
  static const String _keyComments = 'comments';

  // 初始化存储服务
  Future<bool> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      return true;
    } catch (e) {
      print('存储服务初始化失败: $e');
      return false;
    }
  }

  // 确保已初始化
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  // 保存语音记录列表
  Future<bool> saveVoiceRecords(List<VoiceRecord> records) async {
    try {
      await _ensureInitialized();
      final jsonList = records.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(_keyVoiceRecords, jsonString);
    } catch (e) {
      print('保存语音记录失败: $e');
      return false;
    }
  }

  // 获取语音记录列表
  Future<List<VoiceRecord>> getVoiceRecords() async {
    try {
      await _ensureInitialized();
      final jsonString = _prefs!.getString(_keyVoiceRecords);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => VoiceRecord.fromJson(json)).toList();
    } catch (e) {
      print('获取语音记录失败: $e');
      return [];
    }
  }

  // 添加语音记录
  Future<bool> addVoiceRecord(VoiceRecord record) async {
    try {
      final records = await getVoiceRecords();
      records.add(record);
      return await saveVoiceRecords(records);
    } catch (e) {
      print('添加语音记录失败: $e');
      return false;
    }
  }

  // 更新语音记录
  Future<bool> updateVoiceRecord(VoiceRecord record) async {
    try {
      final records = await getVoiceRecords();
      final index = records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        records[index] = record;
        return await saveVoiceRecords(records);
      }
      return false;
    } catch (e) {
      print('更新语音记录失败: $e');
      return false;
    }
  }

  // 删除语音记录
  Future<bool> deleteVoiceRecord(String recordId) async {
    try {
      final records = await getVoiceRecords();
      records.removeWhere((r) => r.id == recordId);
      return await saveVoiceRecords(records);
    } catch (e) {
      print('删除语音记录失败: $e');
      return false;
    }
  }

  // 保存用户资料
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      await _ensureInitialized();
      final jsonString = jsonEncode(profile.toJson());
      return await _prefs!.setString(_keyUserProfile, jsonString);
    } catch (e) {
      print('保存用户资料失败: $e');
      return false;
    }
  }

  // 获取用户资料
  Future<UserProfile?> getUserProfile() async {
    try {
      await _ensureInitialized();
      final jsonString = _prefs!.getString(_keyUserProfile);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString);
      return UserProfile.fromJson(json);
    } catch (e) {
      print('获取用户资料失败: $e');
      return null;
    }
  }

  // 清除用户资料
  Future<bool> clearUserProfile() async {
    try {
      await _ensureInitialized();
      return await _prefs!.remove(_keyUserProfile);
    } catch (e) {
      print('清除用户资料失败: $e');
      return false;
    }
  }

  // 保存聊天消息列表
  Future<bool> saveChatMessages(List<ChatMessage> messages) async {
    try {
      await _ensureInitialized();
      final jsonList = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(_keyChatMessages, jsonString);
    } catch (e) {
      print('保存聊天消息失败: $e');
      return false;
    }
  }

  // 获取聊天消息列表
  Future<List<ChatMessage>> getChatMessages() async {
    try {
      await _ensureInitialized();
      final jsonString = _prefs!.getString(_keyChatMessages);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('获取聊天消息失败: $e');
      return [];
    }
  }

  // 添加聊天消息
  Future<bool> addChatMessage(ChatMessage message) async {
    try {
      final messages = await getChatMessages();
      messages.add(message);
      return await saveChatMessages(messages);
    } catch (e) {
      print('添加聊天消息失败: $e');
      return false;
    }
  }

  // 保存心情数据列表
  Future<bool> saveMoodData(List<MoodData> moodList) async {
    try {
      await _ensureInitialized();
      final jsonList = moodList.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(_keyMoodData, jsonString);
    } catch (e) {
      print('保存心情数据失败: $e');
      return false;
    }
  }

  // 获取心情数据列表
  Future<List<MoodData>> getMoodData() async {
    try {
      await _ensureInitialized();
      final jsonString = _prefs!.getString(_keyMoodData);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => MoodData.fromJson(json)).toList();
    } catch (e) {
      print('获取心情数据失败: $e');
      return [];
    }
  }

  // 添加心情数据
  Future<bool> addMoodData(MoodData mood) async {
    try {
      final moodList = await getMoodData();
      moodList.add(mood);
      return await saveMoodData(moodList);
    } catch (e) {
      print('添加心情数据失败: $e');
      return false;
    }
  }

  // 保存应用设置
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      await _ensureInitialized();
      final jsonString = jsonEncode(settings);
      return await _prefs!.setString(_keyAppSettings, jsonString);
    } catch (e) {
      print('保存应用设置失败: $e');
      return false;
    }
  }

  // 获取应用设置
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      await _ensureInitialized();
      final jsonString = _prefs!.getString(_keyAppSettings);
      if (jsonString == null) return {};

      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      print('获取应用设置失败: $e');
      return {};
    }
  }

  // 保存最后打开日期
  Future<bool> saveLastOpenDate(DateTime date) async {
    try {
      await _ensureInitialized();
      return await _prefs!.setString(_keyLastOpenDate, date.toIso8601String());
    } catch (e) {
      print('保存最后打开日期失败: $e');
      return false;
    }
  }

  // 获取最后打开日期
  Future<DateTime?> getLastOpenDate() async {
    try {
      await _ensureInitialized();
      final dateString = _prefs!.getString(_keyLastOpenDate);
      if (dateString == null) return null;

      return DateTime.parse(dateString);
    } catch (e) {
      print('获取最后打开日期失败: $e');
      return null;
    }
  }

  // 保存每日语录
  Future<bool> saveDailyQuote(String quote) async {
    try {
      await _ensureInitialized();
      return await _prefs!.setString(_keyDailyQuote, quote);
    } catch (e) {
      print('保存每日语录失败: $e');
      return false;
    }
  }

  // 获取每日语录
  Future<String?> getDailyQuote() async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(_keyDailyQuote);
    } catch (e) {
      print('获取每日语录失败: $e');
      return null;
    }
  }

  // 清除所有数据
  Future<bool> clearAllData() async {
    try {
      await _ensureInitialized();
      return await _prefs!.clear();
    } catch (e) {
      print('清除所有数据失败: $e');
      return false;
    }
  }

  // 清除特定类型的数据
  Future<bool> clearData(String key) async {
    try {
      await _ensureInitialized();
      return await _prefs!.remove(key);
    } catch (e) {
      print('清除数据失败: $e');
      return false;
    }
  }

  // ========== 评论数据管理 ==========
  
  // 保存评论列表
  Future<bool> saveComments(String postId, List<Comment> comments) async {
    try {
      await _ensureInitialized();
      final key = '${_keyComments}_$postId';
      final jsonList = comments.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(key, jsonString);
    } catch (e) {
      print('保存评论失败: $e');
      return false;
    }
  }

  // 获取评论列表
  Future<List<Comment>> getComments(String postId) async {
    try {
      await _ensureInitialized();
      final key = '${_keyComments}_$postId';
      final jsonString = _prefs!.getString(key);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      print('获取评论失败: $e');
      return [];
    }
  }

  // 添加评论
  Future<bool> addComment(String postId, Comment comment) async {
    try {
      final comments = await getComments(postId);
      comments.add(comment);
      return await saveComments(postId, comments);
    } catch (e) {
      print('添加评论失败: $e');
      return false;
    }
  }

  // 删除评论
  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      final comments = await getComments(postId);
      comments.removeWhere((c) => c.id == commentId);
      return await saveComments(postId, comments);
    } catch (e) {
      print('删除评论失败: $e');
      return false;
    }
  }

  // 删除特定帖子的所有评论
  Future<bool> deleteCommentsForPost(String postId) async {
    try {
      await _ensureInitialized();
      final key = '${_keyComments}_$postId';
      return await _prefs!.remove(key);
    } catch (e) {
      print('删除帖子评论失败: $e');
      return false;
    }
  }

  // 获取评论数量
  Future<int> getCommentCountForPost(String postId) async {
    try {
      final comments = await getComments(postId);
      return comments.length;
    } catch (e) {
      print('获取评论数量失败: $e');
      return 0;
    }
  }
} 