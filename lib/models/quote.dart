import 'package:intl/intl.dart';

class Quote {
  final String id;
  final String content;
  final String? author;
  final DateTime timestamp;
  final bool isFavorite;
  final bool isOfficial;

  Quote({
    required this.id,
    required this.content,
    this.author,
    required this.timestamp,
    this.isFavorite = false,
    this.isOfficial = false,
  });

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

  Quote copyWith({
    String? id,
    String? content,
    String? author,
    DateTime? timestamp,
    bool? isFavorite,
    bool? isOfficial,
  }) {
    return Quote(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      isOfficial: isOfficial ?? this.isOfficial,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
      'isOfficial': isOfficial,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      content: json['content'],
      author: json['author'],
      timestamp: DateTime.parse(json['timestamp']),
      isFavorite: json['isFavorite'] ?? false,
      isOfficial: json['isOfficial'] ?? false,
    );
  }
} 