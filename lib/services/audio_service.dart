import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  bool _isInitialized = false;
  bool _isPlaying = false;
  String? _currentPlayingPath;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  String? get currentPlayingPath => _currentPlayingPath;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  // 初始化音频服务
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      print('正在初始化音频服务...');

      // 设置音频会话 - 为iOS优化
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      
      // 设置播放器监听
      _player.onPlayerStateChanged.listen((PlayerState state) {
        print('Player state changed: $state');
        _isPlaying = state == PlayerState.playing;
      });

      _player.onPositionChanged.listen((Duration position) {
        // print('Position changed: $position');
        _currentPosition = position;
      });

      _player.onDurationChanged.listen((Duration duration) {
        print('Audio duration changed: $duration');
        _totalDuration = duration;
      });

      _player.onPlayerComplete.listen((_) {
        print('Audio playback completed');
        _isPlaying = false;
        _currentPosition = Duration.zero;
        _currentPlayingPath = null;
      });

      // 设置释放模式
      await _player.setReleaseMode(ReleaseMode.stop);
      
      print('音频服务初始化完成');
      _isInitialized = true;
      return true;
    } catch (e) {
      print('音频服务初始化失败: $e');
      return false;
    }
  }

  // 播放音频文件
  Future<bool> playAudio(String filePath) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      print('Attempting to play audio from: $filePath');

      // 停止当前播放
      if (_isPlaying) {
        await stopAudio();
      }

      // 重置状态
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;

      // 检查文件路径并播放
      if (filePath.startsWith('assets/')) {
        // 处理assets路径 - 移除 'assets/' 前缀
        final assetPath = filePath.substring(7); // 去掉 'assets/' 前缀
        print('Playing from assets: $assetPath');
        print('Full asset path for debug: $filePath');
        
        // 先加载音频以获取时长
        Source source = AssetSource(assetPath);
        await _player.setSource(source);
        await Future.delayed(Duration(milliseconds: 200)); // 等待时长信息加载
        
        // 开始播放
        await _player.resume();
      } else {
        // 处理本地文件路径
        final file = File(filePath);
        if (!await file.exists()) {
          print('音频文件不存在: $filePath');
          return false;
        }
        print('Playing from file: $filePath');
        
        // 先加载音频以获取时长
        Source source = DeviceFileSource(filePath);
        await _player.setSource(source);
        await Future.delayed(Duration(milliseconds: 200)); // 等待时长信息加载
        
        // 开始播放
        await _player.resume();
      }

      _currentPlayingPath = filePath;
      _isPlaying = true;
      
      return true;
    } catch (e) {
      print('播放音频失败: $e');
      _isPlaying = false;
      _currentPlayingPath = null;
      return false;
    }
  }

  // 暂停播放
  Future<void> pauseAudio() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      print('暂停播放失败: $e');
    }
  }

  // 恢复播放
  Future<void> resumeAudio() async {
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      print('恢复播放失败: $e');
    }
  }

  // 停止播放
  Future<void> stopAudio() async {
    try {
      await _player.stop();
      _currentPosition = Duration.zero;
      _currentPlayingPath = null;
      _isPlaying = false;
    } catch (e) {
      print('停止播放失败: $e');
    }
  }

  // 设置播放位置
  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print('设置播放位置失败: $e');
    }
  }

  // 预加载音频以获取时长
  Future<Duration?> preloadAudio(String filePath) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      Source source;
      if (filePath.startsWith('assets/')) {
        final assetPath = filePath.substring(7);
        source = AssetSource(assetPath);
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          return null;
        }
        source = DeviceFileSource(filePath);
      }

      // 设置音频源但不播放
      await _player.setSource(source);
      
      // 等待时长信息加载
      await Future.delayed(Duration(milliseconds: 200));
      
      return _totalDuration;
    } catch (e) {
      print('预加载音频失败: $e');
      return null;
    }
  }

  // 释放资源
  Future<void> dispose() async {
    try {
      await _player.dispose();
      _isInitialized = false;
    } catch (e) {
      print('释放音频资源失败: $e');
    }
  }

} 