import 'voice_record.dart';
import 'quote.dart';

class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? signature;
  final int likedPosts;
  final int likedQuotes;
  final int moodRecords;
  final double averageMood;
  final List<VoiceRecord> recentRecords;
  final List<VoiceRecord> favoriteRecords;
  final List<Quote> favoriteQuotes;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.signature,
    required this.likedPosts,
    required this.likedQuotes,
    required this.moodRecords,
    required this.averageMood,
    required this.recentRecords,
    required this.favoriteRecords,
    required this.favoriteQuotes,
  });

  // 创建默认用户配置文件
  factory UserProfile.defaultProfile() {
    final now = DateTime.now();
    
    // 创建一些默认的心声记录
    final defaultRecords = [
      VoiceRecord(
        id: 'default_1',
        title: '今日心情记录',
        voicePath: 'mock_voice_1', // 模拟语音路径
        timestamp: now.subtract(Duration(hours: 2)),
        duration: Duration(minutes: 1, seconds: 30),
        isFavorite: false,
        description: '记录今天的心情变化，感受生活的美好',
        moodScore: 7.5,
      ),
      VoiceRecord(
        id: 'default_2',
        title: '生活感悟',
        voicePath: 'mock_voice_2',
        timestamp: now.subtract(Duration(days: 1, hours: 5)),
        duration: Duration(minutes: 2, seconds: 15),
        isFavorite: true,
        description: '对生活的思考，珍惜当下的每一刻',
        moodScore: 8.0,
      ),
      VoiceRecord(
        id: 'default_3',
        title: '内心独白',
        voicePath: 'mock_voice_3',
        timestamp: now.subtract(Duration(days: 2, hours: 8)),
        duration: Duration(minutes: 1, seconds: 45),
        isFavorite: false,
        description: '静下心来，聆听内心的声音',
        moodScore: 6.5,
      ),
    ];

    // 创建一些默认的喜欢语录
    final defaultQuotes = [
      Quote(
        id: 'quote_1',
        content: '生活中不是缺少美，而是缺少发现美的眼睛。',
        author: '罗丹',
        timestamp: now.subtract(Duration(days: 1)),
        isFavorite: true,
        isOfficial: true,
      ),
      Quote(
        id: 'quote_2',
        content: '把每一个平凡的日子，过成诗意的模样。',
        timestamp: now.subtract(Duration(days: 2)),
        isFavorite: true,
        isOfficial: true,
      ),
    ];

    return UserProfile(
      id: 'default_user',
      name: '暖暖心语',
      signature: '用声音记录生活点滴 ✨',
      likedPosts: 0,
      likedQuotes: defaultQuotes.length,
      moodRecords: 15,
      averageMood: 7.5,
      recentRecords: defaultRecords,
      favoriteRecords: [],
      favoriteQuotes: defaultQuotes,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? signature,
    int? likedPosts,
    int? likedQuotes,
    int? moodRecords,
    double? averageMood,
    List<VoiceRecord>? recentRecords,
    List<VoiceRecord>? favoriteRecords,
    List<Quote>? favoriteQuotes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      signature: signature ?? this.signature,
      likedPosts: likedPosts ?? this.likedPosts,
      likedQuotes: likedQuotes ?? this.likedQuotes,
      moodRecords: moodRecords ?? this.moodRecords,
      averageMood: averageMood ?? this.averageMood,
      recentRecords: recentRecords ?? this.recentRecords,
      favoriteRecords: favoriteRecords ?? this.favoriteRecords,
      favoriteQuotes: favoriteQuotes ?? this.favoriteQuotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'signature': signature,
      'likedPosts': likedPosts,
      'likedQuotes': likedQuotes,
      'moodRecords': moodRecords,
      'averageMood': averageMood,
      'recentRecords': recentRecords.map((r) => r.toJson()).toList(),
      'favoriteRecords': favoriteRecords.map((r) => r.toJson()).toList(),
      'favoriteQuotes': favoriteQuotes.map((q) => q.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      signature: json['signature'],
      likedPosts: json['likedPosts'] ?? 0,
      likedQuotes: json['likedQuotes'] ?? 0,
      moodRecords: json['moodRecords'] ?? 0,
      averageMood: json['averageMood'] ?? 5.0,
      recentRecords: (json['recentRecords'] as List)
          .map((r) => VoiceRecord.fromJson(r))
          .toList(),
      favoriteRecords: (json['favoriteRecords'] as List?)
          ?.map((r) => VoiceRecord.fromJson(r))
          .toList() ?? [],
      favoriteQuotes: (json['favoriteQuotes'] as List?)
          ?.map((q) => Quote.fromJson(q))
          .toList() ?? [],
    );
  }

  Duration get totalDuration => recentRecords.fold(
    Duration.zero,
    (total, record) => total + record.duration,
  );
} 