import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VoiceRecord {
  final String id;
  final String title;
  final String? description;
  final String voicePath;
  final DateTime timestamp;
  final Duration duration;
  final bool isFavorite;
  final double? moodScore;
  final String? userAvatar;
  final String? imageUrl;

  VoiceRecord({
    required this.id,
    required this.title,
    this.description,
    required this.voicePath,
    required this.duration,
    DateTime? timestamp,
    this.isFavorite = false,
    this.moodScore,
    this.userAvatar,
    this.imageUrl,
  }) : this.timestamp = timestamp ?? DateTime.now();

  // 格式化日期显示
  String get formattedDate {
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
      return DateFormat('MM-dd HH:mm').format(timestamp);
    }
  }

  // 格式化时长显示
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // 复制并修改属性
  VoiceRecord copyWith({
    String? id,
    String? title,
    String? description,
    String? voicePath,
    DateTime? timestamp,
    Duration? duration,
    bool? isFavorite,
    double? moodScore,
    String? userAvatar,
    String? imageUrl,
  }) {
    return VoiceRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      voicePath: voicePath ?? this.voicePath,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      moodScore: moodScore ?? this.moodScore,
      userAvatar: userAvatar ?? this.userAvatar,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'voicePath': voicePath,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration.inMilliseconds,
      'isFavorite': isFavorite,
      'moodScore': moodScore,
      'userAvatar': userAvatar,
      'imageUrl': imageUrl,
    };
  }

  // 从JSON创建实例
  factory VoiceRecord.fromJson(Map<String, dynamic> json) {
    return VoiceRecord(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      voicePath: json['voicePath'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: Duration(milliseconds: json['duration']),
      isFavorite: json['isFavorite'] ?? false,
      moodScore: json['moodScore']?.toDouble(),
      userAvatar: json['userAvatar'],
      imageUrl: json['imageUrl'],
    );
  }
} 