import '../utils/avatar_utils.dart';

enum MessageType {
  text,
  voice,
  image,
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final MessageType type;
  final DateTime timestamp;
  final String? voicePath;
  final Duration? voiceDuration;
  final String? imagePath;
  final bool isRead;
  final double? moodScore;
  final String avatar;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.type,
    required this.timestamp,
    this.voicePath,
    this.voiceDuration,
    this.imagePath,
    this.isRead = false,
    this.moodScore,
    String? avatar,
  }) : avatar = avatar ?? (isUser ? AvatarUtils.userAvatar : AvatarUtils.assistantAvatar);

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    MessageType? type,
    DateTime? timestamp,
    String? voicePath,
    Duration? voiceDuration,
    String? imagePath,
    bool? isRead,
    double? moodScore,
    String? avatar,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      voicePath: voicePath ?? this.voicePath,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      imagePath: imagePath ?? this.imagePath,
      isRead: isRead ?? this.isRead,
      moodScore: moodScore ?? this.moodScore,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'voicePath': voicePath,
      'voiceDuration': voiceDuration?.inMilliseconds,
      'imagePath': imagePath,
      'isRead': isRead,
      'moodScore': moodScore,
      'avatar': avatar,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      type: MessageType.values[json['type'] ?? 0],
      timestamp: DateTime.parse(json['timestamp']),
      voicePath: json['voicePath'],
      voiceDuration: json['voiceDuration'] != null 
          ? Duration(milliseconds: json['voiceDuration'])
          : null,
      imagePath: json['imagePath'],
      isRead: json['isRead'] ?? false,
      moodScore: json['moodScore']?.toDouble(),
      avatar: json['avatar'],
    );
  }

  bool get isVoiceMessage => type == MessageType.voice;
  
  bool get isTextMessage => type == MessageType.text;
  
  bool get isImageMessage => type == MessageType.image;

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDuration {
    if (voiceDuration == null) return '';
    final minutes = voiceDuration!.inMinutes;
    final seconds = voiceDuration!.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get displayContent {
    switch (type) {
      case MessageType.voice:
        return '[语音消息]';
      case MessageType.image:
        return '[图片消息]';
      case MessageType.text:
      default:
        return content;
    }
  }

  // 获取相对时间描述
  String getTimeString() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }

  // 获取语音时长描述
  String? getVoiceDurationString() {
    if (voiceDuration == null) return null;
    final minutes = voiceDuration!.inMinutes;
    final seconds = voiceDuration!.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '0:${seconds.toString().padLeft(2, '0')}';
  }

  // 创建AI回复消息的工厂方法
  factory ChatMessage.aiReply({
    required String content,
    double? moodScore,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
      moodScore: moodScore,
    );
  }

  // 创建用户语音消息的工厂方法
  factory ChatMessage.userVoice({
    required String voicePath,
    required Duration voiceDuration,
    String content = '',
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      type: MessageType.voice,
      timestamp: DateTime.now(),
      voicePath: voicePath,
      voiceDuration: voiceDuration,
    );
  }

  // 创建用户文本消息的工厂方法
  factory ChatMessage.userText({
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
  }

  // 创建用户图片消息的工厂方法
  factory ChatMessage.userImage({
    required String imagePath,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      isUser: true,
      type: MessageType.image,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );
  }
} 