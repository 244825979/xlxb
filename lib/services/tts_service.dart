import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 检查TTS引擎
    final available = await _tts.isLanguageAvailable("zh-CN");
    print('TTS zh-CN available: $available');

    // 设置语音参数
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    
    // 在iOS上设置音频会话类别
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
    );

    // 检查是否支持文件生成
    final engines = await _tts.getEngines;
    print('Available TTS engines: $engines');

    _isInitialized = true;
  }

  Future<String?> convertTextToSpeech(String text) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // 生成语音文件路径
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.wav';
      final filePath = '${directory.path}/$fileName';

      // 确保目录存在
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      print('Generating TTS file at: $filePath');

      // 将文字转换为语音文件
      var result = await _tts.synthesizeToFile(text, filePath);
      print('TTS synthesis result: $result');

      // 等待文件生成
      int attempts = 0;
      while (attempts < 10) {
        await Future.delayed(Duration(milliseconds: 500));
        if (await File(filePath).exists()) {
          final file = File(filePath);
          final fileSize = await file.length();
          print('Generated file size: $fileSize bytes');
          if (fileSize > 0) {
            // 尝试播放一下确保文件有效
            await _tts.speak(text);
            await _tts.stop();
            return filePath;
          }
        }
        attempts++;
      }

      print('Failed to generate TTS file after $attempts attempts');
      return null;
    } catch (e) {
      print('文字转语音失败: $e');
      return null;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
} 