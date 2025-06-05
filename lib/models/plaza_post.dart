class PlazaPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isVirtual;
  final double moodScore;
  final bool isLiked;
  final int commentCount;

  const PlazaPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.isVirtual,
    required this.moodScore,
    this.isLiked = false,
    this.commentCount = 0,
  });

  PlazaPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    bool? isVirtual,
    double? moodScore,
    bool? isLiked,
    int? commentCount,
  }) {
    return PlazaPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isVirtual: isVirtual ?? this.isVirtual,
      moodScore: moodScore ?? this.moodScore,
      isLiked: isLiked ?? this.isLiked,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isVirtual': isVirtual,
      'moodScore': moodScore,
      'isLiked': isLiked,
      'commentCount': commentCount,
    };
  }

  factory PlazaPost.fromJson(Map<String, dynamic> json) {
    return PlazaPost(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      isVirtual: json['isVirtual'] ?? true,
      moodScore: json['moodScore']?.toDouble() ?? 0.0,
      isLiked: json['isLiked'] ?? false,
      commentCount: json['commentCount'] ?? 0,
    );
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else {
      return '${createdAt.year}-${createdAt.month}-${createdAt.day}';
    }
  }

  String get userTypeLabel => isVirtual ? '虚拟用户' : '真实用户';
} 