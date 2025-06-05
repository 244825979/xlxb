import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/voice_record.dart';
import '../models/mood_data.dart';
import '../models/quote.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../utils/mock_data.dart';

class ProfileProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();

  // 状态变量
  bool _isLoading = false;
  UserProfile? _userProfile;
  List<MoodData> _weeklyMoodData = [];
  bool _isPlaying = false;
  String? _currentPlayingPath;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;
  List<MoodData> get weeklyMoodData => _weeklyMoodData;
  bool get isPlaying => _isPlaying;
  String? get currentPlayingPath => _currentPlayingPath;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  List<VoiceRecord> get recentRecords => _userProfile?.recentRecords ?? [];
  double get weeklyAverageMood => _calculateWeeklyAverageMood();

  // 播放进度百分比
  double get playProgress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  // 计算本周平均心情
  double _calculateWeeklyAverageMood() {
    if (_weeklyMoodData.isEmpty) return 5.0;
    final sum = _weeklyMoodData.fold(0.0, (sum, mood) => sum + mood.moodScore);
    return sum / _weeklyMoodData.length;
  }

  // 获取心情趋势描述
  String get moodTrendDescription {
    if (_weeklyMoodData.isEmpty) return '开始记录您的心情，了解自己的情感变化吧';
    
    if (_weeklyMoodData.length < 3) return '继续记录心情，我们需要更多数据来分析您的情感趋势';
    
    // 计算最近3天的平均心情
    final recentDays = _weeklyMoodData.take(3).toList();
    final recentAverage = recentDays.fold(0.0, (sum, mood) => sum + mood.moodScore) / recentDays.length;
    
    // 计算整周的平均心情
    final weeklyAverage = weeklyAverageMood;
    
    // 获取本周最高和最低心情
    final maxMood = _weeklyMoodData.map((m) => m.moodScore).reduce((a, b) => a > b ? a : b);
    final minMood = _weeklyMoodData.map((m) => m.moodScore).reduce((a, b) => a < b ? a : b);
    
    // 分析心情变化趋势
    String trendDescription;
    
    if (weeklyAverage >= 8.0) {
      trendDescription = '这周您的心情整体很棒！继续保持这种积极的状态✨';
    } else if (weeklyAverage >= 7.0) {
      trendDescription = '您这周的心情不错，偶尔的小波动很正常，继续加油！😊';
    } else if (weeklyAverage >= 6.0) {
      trendDescription = '这周心情有些起伏，试着找到让自己开心的小事情吧 🌸';
    } else if (weeklyAverage >= 5.0) {
      trendDescription = '这周可能遇到了一些挑战，记住困难只是暂时的，一切都会好起来 🤗';
    } else {
      trendDescription = '最近似乎有些不如意，要记得好好照顾自己，必要时寻求朋友或专业人士的帮助 💙';
    }
    
    // 添加变化幅度的描述
    final moodRange = maxMood - minMood;
    if (moodRange > 3.0) {
      trendDescription += '\n您的心情变化较大，这说明您是一个感情丰富的人';
    } else if (moodRange > 1.5) {
      trendDescription += '\n您的心情有适度的变化，这很正常';
    } else {
      trendDescription += '\n您的心情比较稳定，这是很好的状态';
    }
    
    return trendDescription;
  }

  // 初始化个人档案数据
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 初始化音频服务
      await _audioService.initialize();
      
      // 初始化存储服务
      await _storageService.initialize();

      // 清除已存储的用户资料，强制使用新的默认资料
      await _storageService.clearUserProfile();

      // 加载用户资料
      await _loadUserProfile();

      // 加载本周心情数据
      await _loadWeeklyMoodData();

    } catch (e) {
      print('个人档案初始化失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    await initialize();
  }

  // 加载用户资料
  Future<void> _loadUserProfile() async {
    try {
      // 先尝试从存储中加载
      final savedProfile = await _storageService.getUserProfile();
      
      if (savedProfile != null) {
        _userProfile = savedProfile;
      } else {
        // 如果没有保存的资料，使用默认资料
        _userProfile = UserProfile.defaultProfile();
        // 保存到存储
        await _storageService.saveUserProfile(_userProfile!);
      }
      
    } catch (e) {
      print('加载用户资料失败: $e');
      _userProfile = UserProfile.defaultProfile();
    }
  }

  // 加载本周心情数据
  Future<void> _loadWeeklyMoodData() async {
    try {
      final allMoodData = await _storageService.getMoodData();
      
      if (allMoodData.isNotEmpty) {
        // 过滤本周的数据
        _weeklyMoodData = allMoodData.where((mood) => mood.isThisWeek).toList();
      }
      
      // 如果本周数据不足，用模拟数据补充
      if (_weeklyMoodData.length < 7) {
        _weeklyMoodData = MockData.generateMockMoodData();
        // 保存模拟数据
        for (final mood in _weeklyMoodData) {
          await _storageService.addMoodData(mood);
        }
      }
      
      // 按日期排序，确保数据顺序正确
      _weeklyMoodData.sort((a, b) => a.date.compareTo(b.date));
      
      // 确保数据不为空，如果为空则生成基础数据
      if (_weeklyMoodData.isEmpty) {
        _weeklyMoodData = _generateBasicMoodData();
      }
      
    } catch (e) {
      print('加载本周心情数据失败: $e');
      // 生成基础心情数据作为后备
      _weeklyMoodData = _generateBasicMoodData();
    }
  }

  // 生成基础心情数据
  List<MoodData> _generateBasicMoodData() {
    final now = DateTime.now();
    final moodData = <MoodData>[];
    
    // 生成最近7天（今天之前）的数据
    for (int i = 1; i <= 7; i++) {
      final date = now.subtract(Duration(days: i));
      // 模拟当天可能有多条心情记录，取最高的
      final dailyMoodScores = _generateDailyMoodScores(i);
      final maxMoodScore = dailyMoodScores.reduce((a, b) => a > b ? a : b);
      
      String moodDescription;
      String note;
      
      // 根据日期和心情分数生成描述
      switch (i) {
        case 1: // 昨天
          if (maxMoodScore >= 8.0) {
            moodDescription = '昨天心情很棒';
            note = '完成了重要的事情';
          } else if (maxMoodScore >= 6.0) {
            moodDescription = '昨天还不错';
            note = '平稳度过';
          } else {
            moodDescription = '昨天有些低落';
            note = '遇到了一些困难';
          }
          break;
        case 2: // 前天
          if (maxMoodScore >= 8.0) {
            moodDescription = '心情愉悦';
            note = '和朋友聚会';
          } else if (maxMoodScore >= 6.0) {
            moodDescription = '状态平稳';
            note = '正常的一天';
          } else {
            moodDescription = '情绪一般';
            note = '工作压力较大';
          }
          break;
        case 3:
          if (maxMoodScore >= 8.0) {
            moodDescription = '精神饱满';
            note = '听了喜欢的音乐';
          } else if (maxMoodScore >= 6.0) {
            moodDescription = '心境平和';
            note = '读了一本好书';
          } else {
            moodDescription = '略感疲惫';
            note = '睡眠不足';
          }
          break;
        case 4:
          if (maxMoodScore >= 8.0) {
            moodDescription = '心情明朗';
            note = '天气很好';
          } else if (maxMoodScore >= 6.0) {
            moodDescription = '情绪稳定';
            note = '按计划完成任务';
          } else {
            moodDescription = '感觉焦虑';
            note = '工作任务繁重';
          }
          break;
        case 5:
          if (maxMoodScore >= 8.0) {
            moodDescription = '开心满足';
            note = '收到好消息';
          } else if (maxMoodScore >= 6.0) {
            moodDescription = '心情还好';
            note = '日常生活';
          } else {
            moodDescription = '情绪低沉';
            note = '遇到挫折';
          }
          break;
        case 6:
          if (maxMoodScore >= 8.0) {
            moodDescription = '兴奋愉快';
            note = '有新的发现';
          } else if (maxMoodScore >= 6.0) {
            moodDescription = '平静舒适';
            note = '在家休息';
          } else {
            moodDescription = '心情沉重';
            note = '思考人生';
          }
          break;
        case 7:
          if (maxMoodScore >= 8.0) {
            moodDescription = '充满活力';
            note = '锻炼身体';
          } else if (maxMoodScore >= 6.0) {
            moodDescription = '心态平和';
            note = '冥想放松';
          } else {
            moodDescription = '情绪不佳';
            note = '需要调整状态';
          }
          break;
        default:
          moodDescription = '平静如常';
          note = '普通的一天';
      }
      
      moodData.add(MoodData(
        date: date,
        moodScore: maxMoodScore,
        moodDescription: moodDescription,
        note: note,
      ));
    }
    
    // 按日期正序排列（最早的在前面）
    moodData.sort((a, b) => a.date.compareTo(b.date));
    return moodData;
  }

  // 生成一天内的多个心情分数，模拟一天内心情的变化
  List<double> _generateDailyMoodScores(int daysAgo) {
    // 基于天数生成不同的心情波动模式
    switch (daysAgo) {
      case 1: // 昨天 - 心情较好
        return [6.5, 7.2, 8.1, 7.8];
      case 2: // 前天 - 平稳
        return [6.0, 6.8, 7.0, 6.5];
      case 3: // 3天前 - 有起伏
        return [5.5, 7.5, 6.8, 8.2];
      case 4: // 4天前 - 情绪一般
        return [5.0, 5.8, 6.2, 5.5];
      case 5: // 5天前 - 较好
        return [7.0, 8.5, 7.8, 8.0];
      case 6: // 6天前 - 起伏较大
        return [4.5, 6.0, 8.5, 7.2];
      case 7: // 7天前 - 稳定良好
        return [7.5, 8.0, 7.8, 8.2];
      default:
        return [6.0, 6.5, 7.0, 6.8];
    }
  }

  // 根据心情分数获取对应的心情描述
  String _getMoodNoteForScore(double score) {
    if (score >= 9.0) return '心情非常愉悦';
    if (score >= 8.0) return '心情很好';
    if (score >= 7.0) return '心情不错';
    if (score >= 6.0) return '心情一般';
    if (score >= 5.0) return '心情低落';
    return '心情很差';
  }

  // 音频播放控制方法
  Future<void> startPlayback(VoiceRecord record) async {
    try {
      if (_currentPlayingPath == record.voicePath && _isPlaying) {
        // 如果是同一个文件且正在播放，则暂停
        await pausePlayback();
      } else {
        // 开始播放新的文件
        _currentPlayingPath = record.voicePath;
        await _audioService.playAudio(record.voicePath);
        _isPlaying = true;
        _totalDuration = record.duration;
        notifyListeners();
      }
    } catch (e) {
      print('播放失败: $e');
    }
  }

  Future<void> pausePlayback() async {
    try {
      await _audioService.pauseAudio();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      print('暂停失败: $e');
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _audioService.stopAudio();
      _isPlaying = false;
      _currentPlayingPath = null;
      _currentPosition = Duration.zero;
      notifyListeners();
    } catch (e) {
      print('停止播放失败: $e');
    }
  }

  // 检查指定记录是否正在播放
  bool isRecordPlaying(VoiceRecord record) {
    return _isPlaying && _currentPlayingPath == record.voicePath;
  }

  // 更新播放进度
  void updatePlaybackProgress() {
    if (_isPlaying && _currentPlayingPath != null) {
      _currentPosition = _audioService.currentPosition;
      notifyListeners();
    }
  }

  // 切换语音记录收藏状态
  Future<void> toggleFavorite(VoiceRecord record) async {
    try {
      if (_userProfile == null) return;

      // 更新记录的收藏状态
      final updatedRecord = record.copyWith(isFavorite: !record.isFavorite);
      
      // 更新用户资料中的记录
      final updatedRecords = _userProfile!.recentRecords.map((r) {
        return r.id == record.id ? updatedRecord : r;
      }).toList();
      
      // 更新收藏列表
      final updatedFavorites = List<VoiceRecord>.from(_userProfile!.favoriteRecords);
      if (updatedRecord.isFavorite) {
        if (!updatedFavorites.any((r) => r.id == updatedRecord.id)) {
          updatedFavorites.add(updatedRecord);
        }
      } else {
        updatedFavorites.removeWhere((r) => r.id == updatedRecord.id);
      }
      
      _userProfile = _userProfile!.copyWith(
        recentRecords: updatedRecords,
        favoriteRecords: updatedFavorites,
      );
      
      // 保存到存储
      await _storageService.saveUserProfile(_userProfile!);
      
      notifyListeners();
    } catch (e) {
      print('切换收藏状态失败: $e');
    }
  }

  // 删除语音记录
  Future<void> deleteVoiceRecord(VoiceRecord record) async {
    try {
      if (_userProfile == null) return;

      // 从用户资料中移除记录
      final updatedRecords = _userProfile!.recentRecords.where((r) => r.id != record.id).toList();
      final updatedFavorites = _userProfile!.favoriteRecords.where((r) => r.id != record.id).toList();
      
      _userProfile = _userProfile!.copyWith(
        recentRecords: updatedRecords,
        favoriteRecords: updatedFavorites,
      );
      
      // 从存储中删除
      await _storageService.saveUserProfile(_userProfile!);
      
      notifyListeners();
    } catch (e) {
      print('删除语音记录失败: $e');
    }
  }

  // 更新用户信息
  Future<void> updateUserInfo({
    String? name,
    String? signature,
    String? avatarUrl,
  }) async {
    try {
      if (_userProfile == null) return;

      _userProfile = _userProfile!.copyWith(
        name: name,
        signature: signature,
        avatarUrl: avatarUrl,
      );
      
      await _storageService.saveUserProfile(_userProfile!);
      notifyListeners();
    } catch (e) {
      print('更新用户信息失败: $e');
    }
  }

  // 添加新动态到个人中心（从广场发布）
  void addNewDynamicFromPlaza(dynamic plazaPost) {
    try {
      // 将PlazaPost转换为VoiceRecord
      final newVoiceRecord = VoiceRecord(
        id: plazaPost.id,
        title: plazaPost.content.length > 20 
            ? '${plazaPost.content.substring(0, 20)}...' 
            : plazaPost.content,
        description: plazaPost.content,
        timestamp: plazaPost.createdAt,
        voicePath: 'dynamic_${plazaPost.id}', // 标记为动态发布的记录
        duration: Duration(seconds: 0), // 动态发布没有语音时长
        isFavorite: false,
        moodScore: plazaPost.moodScore,
      );

      // 添加到用户资料的最近记录中
      if (_userProfile != null) {
        final updatedRecords = [newVoiceRecord, ..._userProfile!.recentRecords];
        
        // 更新用户资料
        _userProfile = _userProfile!.copyWith(
          recentRecords: updatedRecords,
        );

        // 保存到存储
        _storageService.saveUserProfile(_userProfile!);

        // 通知UI更新
        notifyListeners();
        
        print('新动态已添加到个人中心: ${newVoiceRecord.title}');
      }
    } catch (e) {
      print('添加新动态到个人中心失败: $e');
    }
  }

  // 更新动态收藏状态
  void updateDynamicFavoriteStatus(String dynamicId, bool isFavorite) {
    if (_userProfile != null) {
      final updatedRecords = _userProfile!.recentRecords.map((record) {
        if (record.id == dynamicId) {
          return record.copyWith(isFavorite: isFavorite);
        }
        return record;
      }).toList();

      // 更新收藏列表
      final updatedFavorites = List<VoiceRecord>.from(_userProfile!.favoriteRecords);
      final targetRecord = updatedRecords.firstWhere((r) => r.id == dynamicId);
      
      if (isFavorite) {
        if (!updatedFavorites.any((r) => r.id == dynamicId)) {
          updatedFavorites.add(targetRecord);
        }
      } else {
        updatedFavorites.removeWhere((r) => r.id == dynamicId);
      }

      _userProfile = _userProfile!.copyWith(
        recentRecords: updatedRecords,
        favoriteRecords: updatedFavorites,
      );

      // 保存到存储
      _storageService.saveUserProfile(_userProfile!);

      // 通知UI更新
      notifyListeners();
    }
  }

  // 添加喜欢的帖子
  void addLikedPost(VoiceRecord post) {
    if (_userProfile != null) {
      // 检查是否已经存在
      if (!_userProfile!.favoriteRecords.any((r) => r.id == post.id)) {
        final updatedFavorites = [..._userProfile!.favoriteRecords, post];
        
        _userProfile = _userProfile!.copyWith(
          favoriteRecords: updatedFavorites,
          likedPosts: _userProfile!.likedPosts + 1, // 增加喜欢数量
        );

        // 保存到存储
        _storageService.saveUserProfile(_userProfile!);

        // 通知UI更新
        notifyListeners();
        print('Added liked post: ${post.title}');
      }
    }
  }

  // 移除喜欢的帖子
  void removeLikedPost(String postId) {
    if (_userProfile != null) {
      final updatedFavorites = _userProfile!.favoriteRecords.where((r) => r.id != postId).toList();
      
      _userProfile = _userProfile!.copyWith(
        favoriteRecords: updatedFavorites,
        likedPosts: _userProfile!.likedPosts - 1, // 减少喜欢数量
      );

      // 保存到存储
      _storageService.saveUserProfile(_userProfile!);

      // 通知UI更新
      notifyListeners();
      print('Removed liked post: $postId');
    }
  }

  // 添加喜欢的语录
  void addLikedQuote(Quote quote) {
    if (_userProfile != null) {
      // 检查是否已经存在
      if (!_userProfile!.favoriteQuotes.any((q) => q.id == quote.id)) {
        final updatedQuotes = [..._userProfile!.favoriteQuotes, quote];
        
        _userProfile = _userProfile!.copyWith(
          favoriteQuotes: updatedQuotes,
          likedQuotes: _userProfile!.likedQuotes + 1,
        );

        // 保存到存储
        _storageService.saveUserProfile(_userProfile!);

        // 通知UI更新
        notifyListeners();
        print('Added liked quote: ${quote.content}');
      }
    }
  }

  // 移除喜欢的语录
  void removeLikedQuote(String quoteId) {
    if (_userProfile != null) {
      final updatedQuotes = _userProfile!.favoriteQuotes.where((q) => q.id != quoteId).toList();
      
      _userProfile = _userProfile!.copyWith(
        favoriteQuotes: updatedQuotes,
        likedQuotes: _userProfile!.likedQuotes - 1,
      );

      // 保存到存储
      _storageService.saveUserProfile(_userProfile!);

      // 通知UI更新
      notifyListeners();
      print('Removed liked quote: $quoteId');
    }
  }

  // 切换语录喜欢状态
  void toggleQuoteLike(Quote quote) {
    if (quote.isFavorite) {
      removeLikedQuote(quote.id);
    } else {
      addLikedQuote(quote.copyWith(isFavorite: true));
    }
  }

  @override
  void dispose() {
    stopPlayback();
    super.dispose();
  }
} 