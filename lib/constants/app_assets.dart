class AppAssets {
  // Logo资源
  static const String logo = 'assets/images/logo1024.png';
  
  // 头像资源
  static const String defaultAvatar = 'assets/images/avatars/default_avatar.png';
  static const String aiAvatar = 'assets/images/zhushou_image/zhushou.jpeg';
  
  // 背景图片
  static const String moodBackground = 'assets/images/backgrounds/mood_bg.png';
  static const String homeBackground = 'assets/images/backgrounds/home_bg.png';
  
  // 广场图片
  static const List<String> guangchangImages = [
    'assets/images/guangchang/guangchang_1.jpeg',
    'assets/images/guangchang/guangchang_2.jpeg',
    'assets/images/guangchang/guangchang_3.jpeg',
    'assets/images/guangchang/guangchang_4.jpeg',
    'assets/images/guangchang/guangchang_5.jpeg',
    'assets/images/guangchang/guangchang_6.jpeg',
    'assets/images/guangchang/guangchang_7.jpeg',
    'assets/images/guangchang/guangchang_8.jpeg',
  ];
  
  // 音频文件
  static const String voice1 = 'assets/audio/voice/voice_1.mp3';
  static const String voice2 = 'assets/audio/voice/voice_2.mp3';
  static const String voice3 = 'assets/audio/voice/voice_3.mp3';
  
  // 心情图片
  static const List<String> moodImages = [
    'assets/images/xinqing/xinqing_1.png',
    'assets/images/xinqing/xinqing_2.png',
    'assets/images/xinqing/xinqing_3.png',
    'assets/images/xinqing/xinqing_4.png',
    'assets/images/xinqing/xinqing_5.png',
  ];
  
  // 获取用户头像列表
  static List<String> get userAvatars {
    List<String> avatars = [];
    for (int i = 1; i <= 31; i++) {
      avatars.add('assets/images/head_image/head_$i.jpeg');
    }
    return avatars;
  }
  
  // 获取示例音频列表
  static List<String> get sampleAudios => [
    voice1,
    voice2,
    voice3,
  ];
  
  // 获取心情图片
  static String getMoodImage(double moodScore) {
    if (moodScore >= 9.0) return moodImages[0]; // 超开心
    if (moodScore >= 7.0) return moodImages[1]; // 舒畅
    if (moodScore >= 4.0) return moodImages[2]; // 一般
    if (moodScore >= 2.0) return moodImages[3]; // 不开心
    return moodImages[4]; // 难过
  }
} 