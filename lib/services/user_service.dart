class UserService {
  static const String _currentUserId = 'current_user_id';
  
  // 获取当前用户ID
  static String getCurrentUserId() {
    return _currentUserId;
  }
  
  // 检查是否为当前用户
  static bool isCurrentUser(String userId) {
    return userId == _currentUserId;
  }
} 