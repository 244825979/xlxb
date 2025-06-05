import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../models/mood_data.dart';
import '../utils/mock_data.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;

  // Getters
  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // 初始化通知数据
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadNotifications();
    } catch (e) {
      print('加载通知失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载通知数据
  Future<void> _loadNotifications() async {
    // 这里模拟从服务器加载通知
    await Future.delayed(Duration(milliseconds: 500));
    
    final now = DateTime.now();
    _notifications = [
      // 每日心情提醒
      if (now.hour >= 20 && !_hasTodayMoodRecord())
        NotificationItem(
          id: 'mood_reminder_${now.day}',
          title: '记录今日心情',
          content: '今天过得怎么样？记录一下此刻的心情吧',
          type: NotificationType.dailyMoodReminder,
          createdAt: now,
        ),

      // 新语录推送
      NotificationItem(
        id: 'quote_${now.millisecondsSinceEpoch}',
        title: '每日心灵语录',
        content: MockData.getRandomDailyQuote(),
        type: NotificationType.newQuote,
        createdAt: now.subtract(Duration(hours: 2)),
      ),

      // 新音乐上线
      NotificationItem(
        id: 'music_${now.millisecondsSinceEpoch}',
        title: '新音乐上线',
        content: '《晨曦微光》等3首新曲目已上线，快来聆听吧',
        type: NotificationType.newMusic,
        createdAt: now.subtract(Duration(hours: 5)),
        data: {
          'trackIds': ['voice_1', 'voice_2', 'voice_3'],
        },
      ),

      // 周报通知
      if (now.weekday == DateTime.monday)
        NotificationItem(
          id: 'weekly_${now.year}_${now.month}_${now.weekOfMonth}',
          title: '上周心情周报',
          content: '查看上周的心情变化，了解自己的情绪轨迹',
          type: NotificationType.weeklyReport,
          createdAt: now.subtract(Duration(hours: 1)),
          data: {
            'weekStart': now.subtract(Duration(days: 7)),
            'weekEnd': now.subtract(Duration(days: 1)),
          },
        ),

      // 系统消息
      NotificationItem(
        id: 'system_${now.millisecondsSinceEpoch}',
        title: '系统更新提醒',
        content: '我们增加了更多精美的音乐素材，优化了播放体验',
        type: NotificationType.systemMessage,
        createdAt: now.subtract(Duration(days: 1)),
      ),
    ];
  }

  // 标记通知为已读
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].markAsRead();
      notifyListeners();
    }
  }

  // 标记所有通知为已读
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.markAsRead()).toList();
    notifyListeners();
  }

  // 删除通知
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // 清空所有通知
  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
  }

  // 检查今天是否已经记录心情
  bool _hasTodayMoodRecord() {
    // TODO: 实际应用中需要从 HomeProvider 获取今日心情数据
    return false;
  }
}

extension DateTimeExtension on DateTime {
  int get weekOfMonth {
    var date = this;
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    int sum = firstDayOfMonth.weekday - 1 + date.day;
    return sum ~/ 7 + 1;
  }
} 