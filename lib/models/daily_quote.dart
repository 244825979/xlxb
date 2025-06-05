class DailyQuote {
  final String id;
  final DateTime date;
  final String content;
  final String? nickname;
  final bool isOfficial;

  const DailyQuote({
    required this.id,
    required this.date,
    required this.content,
    this.nickname,
    this.isOfficial = false,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference == 2) {
      return '前天';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'nickname': nickname,
      'isOfficial': isOfficial,
    };
  }

  factory DailyQuote.fromJson(Map<String, dynamic> json) {
    return DailyQuote(
      id: json['id'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      nickname: json['nickname'],
      isOfficial: json['isOfficial'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyQuote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 