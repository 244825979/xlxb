import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderService {
  static final RecorderService _instance = RecorderService._internal();
  factory RecorderService() => _instance;
  RecorderService._internal();

  FlutterSoundRecorder? _recorder;
  bool _isInitialized = false;
  bool _isRecording = false;

  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    try {
      final microphoneStatus = await Permission.microphone.request();
      final storageStatus = await Permission.storage.request();
      
      return microphoneStatus.isGranted && storageStatus.isGranted;
    } catch (e) {
      print('权限请求失败: $e');
      return false;
    }
  }

  Future<String?> startRecording() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (_recorder == null) return null;

      // 检查权限
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('录音权限被拒绝');
        return null;
      }

      // 生成录音文件路径
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${directory.path}/$fileName';

      // 开始录音
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacMP4,
      );

      _isRecording = true;
      return filePath;
    } catch (e) {
      print('开始录音失败: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (_recorder == null || !_isRecording) return null;

      final filePath = await _recorder!.stopRecorder();
      _isRecording = false;
      
      return filePath;
    } catch (e) {
      print('停止录音失败: $e');
      return null;
    }
  }

  void dispose() async {
    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
    }
    _isInitialized = false;
  }
} 