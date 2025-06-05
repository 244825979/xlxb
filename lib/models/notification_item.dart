import 'package:flutter/material.dart';

enum NotificationType {
  dailyMoodReminder,    // 每日心情提醒
  newQuote,            // 新语录推送
  newMusic,            // 新音乐上线
  weeklyReport,        // 周报通知
  systemMessage,       // 系统消息
}

class NotificationItem {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.data,
  });

  // 获取通知图标
  IconData get icon {
    switch (type) {
      case NotificationType.dailyMoodReminder:
        return Icons.mood;
      case NotificationType.newQuote:
        return Icons.format_quote;
      case NotificationType.newMusic:
        return Icons.music_note;
      case NotificationType.weeklyReport:
        return Icons.analytics;
      case NotificationType.systemMessage:
        return Icons.notifications;
    }
  }

  // 获取通知颜色
  Color get color {
    switch (type) {
      case NotificationType.dailyMoodReminder:
        return Colors.orange;
      case NotificationType.newQuote:
        return Colors.blue;
      case NotificationType.newMusic:
        return Colors.purple;
      case NotificationType.weeklyReport:
        return Colors.green;
      case NotificationType.systemMessage:
        return Colors.grey;
    }
  }

  // 获取相对时间描述
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 创建已读版本
  NotificationItem markAsRead() {
    return NotificationItem(
      id: id,
      title: title,
      content: content,
      type: type,
      createdAt: createdAt,
      isRead: true,
      imageUrl: imageUrl,
      data: data,
    );
  }
} 