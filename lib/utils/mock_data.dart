import '../models/voice_record.dart';
import '../models/user_profile.dart';
import '../models/plaza_post.dart';
import '../models/chat_message.dart';
import '../models/mood_data.dart';
import '../models/quote.dart';
import '../constants/app_assets.dart';
import '../constants/mood_quotes.dart';
import '../services/user_service.dart';

class MockData {
  // 虚拟用户名称列表
  static const List<String> virtualUserNames = [
    '匿名小宇宙',
    '深夜听海人',
    '雨后彩虹',
    '晨光微熹',
    '静谧森林',
    '温柔月光',
    '自由飞鸟',
    '梦想追逐者',
    '心灵旅者',
    '时光漫步',
  ];

  // 广场帖子内容列表
  static const List<String> plazaContents = [
    '今天天气真好，晒着太阳，感觉心里的烦恼都被吹散了。偶尔放空一下，真好。',
    '最近一直在思考人生的意义，虽然有点迷茫，但也在慢慢寻找答案。',
    '虽然遇到了一些小挫折，但相信明天会更好！阳光总在风雨后。',
    '听着雨声，突然想起了小时候的那个午后，奶奶在厨房里忙碌的身影。',
    '工作压力很大，但是看到窗外的夕阳，心情瞬间平静了下来。',
    '今天和朋友聊天，发现原来我们都在为同样的事情烦恼，感觉不那么孤单了。',
    '深夜的城市很安静，只有我和这盏台灯，还有满心的思绪。',
    '春天来了，路边的花都开了，生活总是充满希望的。',
    '有时候觉得自己很渺小，但又觉得每个人都有自己的光芒。',
    '今天做了一个很美的梦，醒来后还想继续那个故事。',
    '生活中总有不如意，但也要学会坦然面对。',
    '看到路边的小花，突然觉得生活中处处都是美好。',
    '有时候静静地看着窗外发呆，也是一种享受。',
    '每个人都在寻找自己的方向，我也在路上。',
    '夜深人静的时候，总会想起很多往事。',
    '生活就像一杯茶，苦涩中带着回甘。',
    '阳光正好，微风不燥，这样的日子真美好。',
    '偶尔放慢脚步，欣赏路边的风景。',
    '心情不好的时候，就去看看天空。',
    '时光匆匆，但美好的记忆永远留在心里。',
  ];

  // AI回复内容列表
  static const List<String> aiResponses = [
    '从您的声音中，我感受到了些许平静与放松。今天过得还不错吗？',
    '嗯，听起来您正在思考一些事情。如果您愿意，可以再多说一些，我会静静倾听。',
    '您的声音里有一种温暖的力量，这让我想到了春日的阳光。',
    '我能感受到您内心的波动，有什么想要分享的吗？',
    '您今天的心情似乎比昨天更加明朗了，这是一个很好的变化。',
    '从您的语调中，我听出了一些疲惫，记得要好好休息哦。',
    '您的声音很有感染力，相信您一定是一个很温暖的人。',
    '听起来您今天经历了一些有趣的事情，愿意和我分享吗？',
  ];

  // 获取每日语录
  static String getRandomDailyQuote() {
    return MoodQuotes.getDailyQuote();
  }

  // 获取随机AI回复
  static String getRandomAiResponse() {
    final index = DateTime.now().millisecond % aiResponses.length;
    return aiResponses[index];
  }

  // 获取随机虚拟用户名
  static String getRandomVirtualUserName() {
    final index = DateTime.now().millisecond % virtualUserNames.length;
    return virtualUserNames[index];
  }

  // 获取随机头像
  static String getRandomAvatar() {
    final index = DateTime.now().millisecond % AppAssets.userAvatars.length;
    return AppAssets.userAvatars[index];
  }

  // 获取随机广场内容
  static String getRandomPlazaContent() {
    final index = DateTime.now().millisecond % plazaContents.length;
    return plazaContents[index];
  }

  // 生成模拟心情数据
  static List<MoodData> generateMockMoodData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final moodData = <MoodData>[];
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      moodData.add(MoodData.random(date: date));
    }
    
    return moodData;
  }

  // 生成模拟语音记录
  static List<VoiceRecord> generateMockVoiceRecords() {
    final now = DateTime.now();
    return [
      VoiceRecord(
        id: 'voice_1',
        title: '早晨的心情分享',
        description: '今天天气真好，心情舒畅',
        voicePath: 'assets/audio/voice/voice_1.mp3',
        duration: Duration(minutes: 1, seconds: 45),
        timestamp: now.subtract(Duration(hours: 2)),
        moodScore: 8.5,
      ),
      VoiceRecord(
        id: 'voice_2',
        title: '午后的感悟',
        description: '工作顺利，充满干劲',
        voicePath: 'assets/audio/voice/voice_2.mp3',
        duration: Duration(minutes: 2, seconds: 15),
        timestamp: now.subtract(Duration(hours: 5)),
        moodScore: 7.8,
      ),
      VoiceRecord(
        id: 'voice_3',
        title: '晚间小记',
        description: '回顾今天的收获',
        voicePath: 'assets/audio/voice/voice_3.mp3',
        duration: Duration(minutes: 1, seconds: 30),
        timestamp: now.subtract(Duration(hours: 8)),
        moodScore: 8.2,
      ),
      VoiceRecord(
        id: 'voice_4',
        title: '深夜感想',
        description: '静静思考生活',
        voicePath: 'assets/audio/voice/voice_4.mp3',
        duration: Duration(minutes: 2, seconds: 45),
        timestamp: now.subtract(Duration(days: 1)),
        moodScore: 7.5,
      ),
      VoiceRecord(
        id: 'voice_5',
        title: '周末随想',
        description: '放松心情，享受生活',
        voicePath: 'assets/audio/voice/voice_5.mp3',
        duration: Duration(minutes: 3, seconds: 20),
        timestamp: now.subtract(Duration(days: 2)),
        moodScore: 9.0,
      ),
    ];
  }

  // 生成模拟用户资料
  static UserProfile generateMockUserProfile() {
    final now = DateTime.now();
    final mockRecords = generateMockVoiceRecords();
    
    // 生成模拟的喜欢语录
    final mockQuotes = [
      Quote(
        id: 'quote_1',
        content: '生活中不是缺少美，而是缺少发现美的眼睛。',
        author: '罗丹',
        timestamp: now.subtract(Duration(days: 1)),
        isFavorite: true,
      ),
      Quote(
        id: 'quote_2',
        content: '把每一个平凡的日子，过成诗意的模样。',
        timestamp: now.subtract(Duration(days: 2)),
        isFavorite: true,
      ),
      Quote(
        id: 'quote_3',
        content: '愿你成为自己喜欢的样子，不抱怨，不将就。',
        author: '泰戈尔',
        timestamp: now.subtract(Duration(days: 3)),
        isFavorite: true,
      ),
    ];

    return UserProfile(
      id: 'user_1',
      name: '心之声',
      avatarUrl: AppAssets.defaultAvatar,
      signature: '温柔是力量',
      likedPosts: 5,
      likedQuotes: mockQuotes.length,
      moodRecords: 15,
      averageMood: 7.0,
      recentRecords: mockRecords,
      favoriteRecords: mockRecords.where((record) => record.isFavorite ?? false).toList(),
      favoriteQuotes: mockQuotes,
    );
  }

  // 生成模拟广场帖子
  static List<PlazaPost> generateMockPlazaPosts() {
    print('Generating mock plaza posts...');
    final now = DateTime.now();
    final posts = <PlazaPost>[];
    
    try {
      // 计算需要生成的帖子总数
      const int imageCount = 16; // 广场图片数量
      const int textPostRatio = 2; // 文字帖子与图片帖子的比例
      final int totalPosts = imageCount * (textPostRatio + 1); // 总帖子数 = 图片数 * (比例 + 1)
      
      print('Generating $totalPosts posts (${imageCount} with images, ${imageCount * textPostRatio} text-only)');
      
      // 获取当前用户ID
      final currentUserId = UserService.getCurrentUserId();
      
      // 生成所有帖子
      for (int i = 0; i < totalPosts; i++) {
        final userIndex = i % virtualUserNames.length;
        final avatarIndex = (i % 31) + 1; // 使用1-31的头像
        final contentIndex = i % plazaContents.length;
        
        // 每三个帖子中的第一个有图片
        final bool hasImage = i % (textPostRatio + 1) == 0;
        final int imageIndex = hasImage ? (i / (textPostRatio + 1)).floor() + 1 : 0;
        
        // 设置用户ID，前面几个帖子设为当前用户的
        final String userId = i < 3 ? currentUserId : 'user_$i';
        final String userName = i < 3 ? '心之声' : virtualUserNames[userIndex];
        
        // 设置审核状态，当前用户的第一个帖子设为审核中
        final ReviewStatus reviewStatus = (i == 0 && userId == currentUserId) 
            ? ReviewStatus.pending 
            : ReviewStatus.approved;
        
        final post = PlazaPost(
          id: 'post_$i',
          userId: userId,
          userName: userName,
          userAvatar: 'assets/images/head_image/head_$avatarIndex.jpeg',
          content: plazaContents[contentIndex],
          imageUrl: hasImage ? 'assets/images/guangchang/guangchang_$imageIndex.jpeg' : null,
          createdAt: now.subtract(Duration(minutes: i * 30)), // 每个帖子间隔30分钟
          isVirtual: i >= 3, // 当前用户的帖子不是虚拟用户
          moodScore: 5.0 + (i % 6) * 0.5,
          commentCount: 0, // 新生成的帖子评论数为0
          reviewStatus: reviewStatus,
        );
        
        posts.add(post);
      }
      
      // 随机打乱帖子顺序，但保持当前用户的审核中帖子在前面
      final pendingPosts = posts.where((post) => post.reviewStatus == ReviewStatus.pending).toList();
      final otherPosts = posts.where((post) => post.reviewStatus != ReviewStatus.pending).toList();
      otherPosts.shuffle();
      
      // 将审核中的帖子放在最前面
      final finalPosts = [...pendingPosts, ...otherPosts];
      
      print('Successfully generated ${finalPosts.length} posts');
      return finalPosts;
      
    } catch (e) {
      print('Error generating mock posts: $e');
      // 返回至少一个默认帖子
      return [
        PlazaPost(
          id: 'default_post',
          userId: 'default_user',
          userName: '心声助手',
          userAvatar: 'assets/images/head_image/head_1.jpeg',
          content: '欢迎来到心声广场！这里是分享心声的地方。',
          imageUrl: 'assets/images/guangchang/guangchang_1.jpeg',
          createdAt: now,
          isVirtual: true,
          moodScore: 8.0,
          commentCount: 0,
          reviewStatus: ReviewStatus.approved,
        )
      ];
    }
  }

  // 生成模拟聊天消息
  static List<ChatMessage> generateMockChatMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg_1',
        content: '您好！我是您的心声助手。准备好记录您的心声了吗？',
        isUser: false,
        timestamp: now.subtract(Duration(minutes: 30)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: 'msg_2',
        content: '今天心情怎么样？想要聊聊发生的事情吗？',
        isUser: false,
        timestamp: now.subtract(Duration(minutes: 25)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: 'msg_3',
        content: aiResponses[0],
        isUser: false,
        timestamp: now.subtract(Duration(minutes: 20)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: 'msg_4',
        content: '非常理解您的感受，有什么想要分享的吗？',
        isUser: false,
        timestamp: now.subtract(Duration(minutes: 15)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: 'msg_5',
        content: aiResponses[1],
        isUser: false,
        timestamp: now.subtract(Duration(minutes: 10)),
        type: MessageType.text,
      ),
    ];
  }
} 