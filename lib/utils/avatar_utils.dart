import 'dart:math';
import '../constants/app_assets.dart';

class AvatarUtils {
  static final Random _random = Random();
  static const int totalAvatars = 31;  // 总头像数量
  
  // 助手头像路径
  static String get assistantAvatar => AppAssets.aiAvatar;
  
  // 用户固定头像
  static String get _userAvatar => AppAssets.userAvatars[11];  // 选择head_12.jpeg (index 11)
  
  // 获取用户头像路径（固定头像）
  static String getUserAvatar() {
    return _userAvatar;
  }
  
  // 用户头像getter（保持向后兼容）
  static String get userAvatar => _userAvatar;
  
  // 获取随机用户头像路径（用于其他用户）
  static String getRandomUserAvatar() {
    final index = _random.nextInt(totalAvatars);
    return AppAssets.userAvatars[index];
  }
} 