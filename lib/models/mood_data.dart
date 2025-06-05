import '../constants/app_assets.dart';

class MoodData {
  final DateTime date;
  final double moodScore;
  final String moodDescription;
  final String? note;
  final List<String> tags;

  MoodData({
    required this.date,
    required this.moodScore,
    required this.moodDescription,
    this.note,
    this.tags = const [],
  });

  MoodData copyWith({
    DateTime? date,
    double? moodScore,
    String? moodDescription,
    String? note,
    List<String>? tags,
  }) {
    return MoodData(
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      moodDescription: moodDescription ?? this.moodDescription,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'moodScore': moodScore,
      'moodDescription': moodDescription,
      'note': note,
      'tags': tags,
    };
  }

  factory MoodData.fromJson(Map<String, dynamic> json) {
    return MoodData(
      date: DateTime.parse(json['date']),
      moodScore: json['moodScore'].toDouble(),
      moodDescription: json['moodDescription'],
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  String get weekday {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }

  String get formattedDate {
    return '${date.month}-${date.day}';
  }

  String get moodLevel {
    if (moodScore >= 9.0) return '超开心';
    if (moodScore >= 7.0) return '舒畅';
    if (moodScore >= 4.0) return '一般';
    if (moodScore >= 2.0) return '不开心';
    return '难过';
  }

  // 根据心情分数获取颜色
  String get moodColor {
    if (moodScore >= 8.0) return '#10B981'; // 绿色
    if (moodScore >= 6.0) return '#60A5FA'; // 蓝色
    if (moodScore >= 4.0) return '#D7EBFF'; // 浅蓝色
    if (moodScore >= 2.0) return '#F59E0B'; // 橙色
    return '#EF4444'; // 红色
  }

  // 获取心情图标
  String get moodIcon {
    if (moodScore >= 8.0) return '😊';
    if (moodScore >= 6.0) return '🙂';
    if (moodScore >= 4.0) return '😐';
    if (moodScore >= 2.0) return '😔';
    return '😢';
  }

  // 判断是否为今天
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // 判断是否为本周
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(Duration(days: 1)));
  }

  // 创建默认心情数据的工厂方法
  factory MoodData.defaultMood({
    required DateTime date,
    String description = '平静',
  }) {
    return MoodData(
      date: date,
      moodScore: 5.0,
      moodDescription: description,
    );
  }

  // 创建随机心情数据的工厂方法（用于模拟数据）
  factory MoodData.random({
    required DateTime date,
  }) {
    final scores = [3.0, 4.5, 6.0, 7.5, 8.0, 5.5, 4.0];
    final descriptions = ['低落', '平静', '愉快', '开心', '兴奋', '放松', '思考'];
    final index = date.weekday % scores.length;
    
    return MoodData(
      date: date,
      moodScore: scores[index],
      moodDescription: descriptions[index],
    );
  }

  // 获取心情图片路径
  String get moodImage {
    return AppAssets.getMoodImage(moodScore);
  }

  // 获取心情标签
  String get moodLabel {
    if (moodScore >= 9.0) return '超开心';
    if (moodScore >= 7.0) return '舒畅';
    if (moodScore >= 4.0) return '一般';
    if (moodScore >= 2.0) return '不开心';
    return '难过';
  }
} 