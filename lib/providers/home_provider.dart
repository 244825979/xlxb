import 'package:flutter/material.dart';
import 'dart:async';
import '../models/voice_record.dart';
import '../models/mood_data.dart';
import '../models/music_track.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../utils/mock_data.dart';
import '../constants/app_assets.dart';
import '../constants/mood_quotes.dart';

class HomeProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();
  Timer? _progressTimer;

  // 状态变量
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _currentPlayingPath;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String _dailyQuote = '';
  VoiceRecord? _todayVoiceRecord;
  MoodData? _todayMood;
  String? _publishedMoodQuote; // 已发布的心情语录
  DateTime? _publishedMoodTime; // 发布时间
  
  // 宁静音乐相关
  List<MusicTrack> _musicTracks = [];
  int _currentTrackIndex = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String? get currentPlayingPath => _currentPlayingPath;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String get dailyQuote => _dailyQuote;
  VoiceRecord? get todayVoiceRecord => _todayVoiceRecord;
  MoodData? get todayMood => _todayMood;
  List<MusicTrack> get musicTracks => _musicTracks;
  int get currentTrackIndex => _currentTrackIndex;
  String? get publishedMoodQuote => _publishedMoodQuote;
  DateTime? get publishedMoodTime => _publishedMoodTime;

  // 播放进度百分比
  double get playProgress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  // 初始化首页数据
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 初始化音频服务
      await _audioService.initialize();
      
      // 初始化存储服务
      await _storageService.initialize();

      // 加载每日语录
      await _loadDailyQuote();

      // 加载今日语音记录
      await _loadTodayVoiceRecord();

      // 加载今日心情
      await _loadTodayMood();

      // 加载宁静音乐轨道
      await _loadMusicTracks();

      // 设置音频播放监听
      _setupAudioListeners();

    } catch (e) {
      print('首页初始化失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 设置音频播放监听
  void _setupAudioListeners() {
    // 启动定时器，定期更新播放状态
    _progressTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (_audioService.isInitialized) {
        _updatePlaybackState();
      }
    });
  }

  // 加载每日语录
  Future<void> _loadDailyQuote() async {
    try {
      // 检查是否是新的一天
      final lastOpenDate = await _storageService.getLastOpenDate();
      final today = DateTime.now();
      
      if (lastOpenDate == null || 
          lastOpenDate.day != today.day || 
          lastOpenDate.month != today.month ||
          lastOpenDate.year != today.year) {
        // 新的一天，获取新的语录
        _dailyQuote = MoodQuotes.getDailyQuote();
        await _storageService.saveDailyQuote(_dailyQuote);
        await _storageService.saveLastOpenDate(today);
      } else {
        // 同一天，使用已保存的语录
        final savedQuote = await _storageService.getDailyQuote();
        _dailyQuote = savedQuote ?? MoodQuotes.getDailyQuote();
      }
    } catch (e) {
      print('加载每日语录失败: $e');
      _dailyQuote = MoodQuotes.getDailyQuote();
    }
  }

  // 加载今日语音记录
  Future<void> _loadTodayVoiceRecord() async {
    try {
      // 这里使用模拟数据，实际应用中可以从存储中获取
      _todayVoiceRecord = VoiceRecord(
        id: 'today_voice',
        title: '今日份的宁静',
        voicePath: AppAssets.voice1,
        timestamp: DateTime.now(),
        duration: Duration(seconds: 45),
        description: '愿你的一天，心如止水，波澜不惊。',
        moodScore: 7.0,
      );
    } catch (e) {
      print('加载今日语音记录失败: $e');
    }
  }

  // 加载今日心情
  Future<void> _loadTodayMood() async {
    try {
      final moodList = await _storageService.getMoodData();
      final today = DateTime.now();
      final lastOpenDate = await _storageService.getLastOpenDate();
      
      // 查找今日心情数据
      final existingMood = moodList.where(
        (mood) => mood.date.day == today.day && 
                  mood.date.month == today.month && 
                  mood.date.year == today.year,
      ).toList();
      
      if (existingMood.isNotEmpty) {
        // 如果已有今日心情数据，使用现有数据
        _todayMood = existingMood.first;
      } else {
        // 检查是否是当天首次启动
        final isFirstLaunchOfDay = lastOpenDate == null || 
            lastOpenDate.day != today.day || 
            lastOpenDate.month != today.month ||
            lastOpenDate.year != today.year;
            
        if (isFirstLaunchOfDay) {
          // 当天首次启动，设置为"超开心"状态
          _todayMood = MoodData(
            date: today,
            moodScore: 10.0,
            moodDescription: '超开心',
          );
          // 保存这个初始心情状态
          await _storageService.addMoodData(_todayMood!);
        } else {
          // 非首次启动，且没有今日心情数据，说明可能是数据加载错误
          // 此时不应重置心情，而是使用一个中性的心情状态
          _todayMood = MoodData(
            date: today,
            moodScore: 5.0,
            moodDescription: '平静',
          );
        }
      }
    } catch (e) {
      print('加载今日心情失败: $e');
      // 出错时使用中性心情状态
      _todayMood = MoodData(
        date: DateTime.now(),
        moodScore: 5.0,
        moodDescription: '平静',
      );
    }
  }

  // 加载宁静音乐轨道
  Future<void> _loadMusicTracks() async {
    try {
      _musicTracks = [
        MusicTrack(
          id: 'voice_1',
          title: '晨曦微光',
          filePath: 'assets/audio/voice/voice_1.mp3',
          description: '如晨露般清新，让心灵在柔和的光芒中苏醒',
          estimatedDuration: Duration(seconds: 42),
        ),
        MusicTrack(
          id: 'voice_2',
          title: '云端漫步',
          filePath: 'assets/audio/voice/voice_2.mp3',
          description: '漂浮在云端，感受内心深处的宁静与安详',
          estimatedDuration: Duration(seconds: 42),
        ),
        MusicTrack(
          id: 'voice_3',
          title: '星河低语',
          filePath: 'assets/audio/voice/voice_3.mp3',
          description: '聆听星河的呢喃，让思绪在浩瀚中沉淀',
          estimatedDuration: Duration(seconds: 42),
        ),
      ];
      
      // 预加载第一首音乐以获取准确时长
      if (_musicTracks.isNotEmpty) {
        await _audioService.preloadAudio(_musicTracks[0].filePath);
      }
      
    } catch (e) {
      print('加载音乐轨道失败: $e');
    }
  }

  // 播放/暂停语音
  Future<void> togglePlayPause() async {
    try {
      if (_todayVoiceRecord == null) return;

      if (_isPlaying) {
        await _audioService.pauseAudio();
      } else {
        await _audioService.playAudio(_todayVoiceRecord!.voicePath);
        _currentPlayingPath = _todayVoiceRecord!.voicePath;
      }
      
      _updatePlaybackState();
    } catch (e) {
      print('播放/暂停失败: $e');
    }
  }

  // 停止播放
  Future<void> stopPlayback() async {
    try {
      await _audioService.stopAudio();
      _updatePlaybackState();
    } catch (e) {
      print('停止播放失败: $e');
    }
  }

  // 设置播放位置
  Future<void> seekTo(double progress) async {
    try {
      if (_totalDuration.inMilliseconds > 0) {
        final position = Duration(
          milliseconds: (_totalDuration.inMilliseconds * progress).round(),
        );
        await _audioService.seekTo(position);
        _updatePlaybackState();
      }
    } catch (e) {
      print('设置播放位置失败: $e');
    }
  }

  // 更新播放状态
  void _updatePlaybackState() {
    final wasPlaying = _isPlaying;
    final oldPosition = _currentPosition;
    final oldDuration = _totalDuration;
    
    _isPlaying = _audioService.isPlaying;
    _currentPosition = _audioService.currentPosition;
    _totalDuration = _audioService.totalDuration;
    _currentPlayingPath = _audioService.currentPlayingPath;
    
    // 如果有任何状态发生变化，通知UI更新
    final hasChanged = wasPlaying != _isPlaying || 
                      oldPosition != _currentPosition || 
                      oldDuration != _totalDuration;
    
    if (hasChanged) {
      notifyListeners();
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    await initialize();
  }

  // 更新今日心情
  Future<void> updateTodayMood(double moodScore, String description) async {
    try {
      final today = DateTime.now();
      final newMood = MoodData(
        date: today,
        moodScore: moodScore,
        moodDescription: description,
      );
      
      await _storageService.addMoodData(newMood);
      _todayMood = newMood;
      
      // 同时发布心情语录
      _publishedMoodQuote = description;
      _publishedMoodTime = today;
      
      notifyListeners();
    } catch (e) {
      print('更新今日心情失败: $e');
    }
  }

  // 发布心情语录
  Future<void> publishMoodQuote(String quote, double moodScore) async {
    try {
      _publishedMoodQuote = quote;
      _publishedMoodTime = DateTime.now();
      
      // 同时更新今日心情
      await updateTodayMood(moodScore, quote);
      
      notifyListeners();
    } catch (e) {
      print('发布心情语录失败: $e');
    }
  }

  // 清除已发布的心情语录
  void clearPublishedMoodQuote() {
    _publishedMoodQuote = null;
    _publishedMoodTime = null;
    notifyListeners();
  }

  // 音乐播放控制方法
  Future<void> toggleMusicPlayPause() async {
    try {
      if (_musicTracks.isEmpty) return;

      final currentTrack = _musicTracks[_currentTrackIndex];
      print('尝试播放/暂停: ${currentTrack.title}, 路径: ${currentTrack.filePath}');

      if (_isPlaying && _currentPlayingPath == currentTrack.filePath) {
        // 暂停当前播放
        await _audioService.pauseAudio();
        print('音乐已暂停');
      } else {
        if (_currentPlayingPath == currentTrack.filePath) {
          // 恢复播放同一首
          await _audioService.resumeAudio();
          print('音乐已恢复');
        } else {
          // 播放新的音轨
          print('开始播放新音轨: ${currentTrack.filePath}');
          final success = await _audioService.playAudio(currentTrack.filePath);
          if (success) {
            _currentPlayingPath = currentTrack.filePath;
            print('音乐播放成功');
          } else {
            print('音乐播放失败');
            return;
          }
        }
      }
      
      // 立即更新状态
      _updatePlaybackState();
      
      // 延迟更新以获取更准确的状态
      Future.delayed(Duration(milliseconds: 200), () {
        _updatePlaybackState();
      });
      
    } catch (e) {
      print('音乐播放/暂停失败: $e');
    }
  }

  // 播放下一首
  Future<void> playNextTrack() async {
    if (_musicTracks.isEmpty) return;
    
    if (_currentTrackIndex < _musicTracks.length - 1) {
      _currentTrackIndex++;
      notifyListeners(); // 立即更新UI显示新的音轨信息
      await _playCurrentTrack();
    }
  }

  // 播放上一首
  Future<void> playPreviousTrack() async {
    if (_musicTracks.isEmpty) return;
    
    if (_currentTrackIndex > 0) {
      _currentTrackIndex--;
      notifyListeners(); // 立即更新UI显示新的音轨信息
      await _playCurrentTrack();
    }
  }

  // 播放当前轨道
  Future<void> _playCurrentTrack() async {
    try {
      if (_musicTracks.isEmpty) return;
      
      final currentTrack = _musicTracks[_currentTrackIndex];
      print('播放当前轨道: ${currentTrack.title}');
      
      final success = await _audioService.playAudio(currentTrack.filePath);
      if (success) {
        _currentPlayingPath = currentTrack.filePath;
        print('轨道播放成功');
      } else {
        print('轨道播放失败');
      }
      
      _updatePlaybackState();
    } catch (e) {
      print('播放当前轨道失败: $e');
    }
  }

  // 音乐进度控制
  Future<void> seekMusicTo(double progress) async {
    try {
      if (_totalDuration.inMilliseconds > 0) {
        final position = Duration(
          milliseconds: (_totalDuration.inMilliseconds * progress).round(),
        );
        await _audioService.seekTo(position);
        _updatePlaybackState();
      }
    } catch (e) {
      print('设置音乐播放位置失败: $e');
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
} 