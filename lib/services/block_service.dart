import 'package:shared_preferences/shared_preferences.dart';

class BlockService {
  static const String _blockedPostsKey = 'blocked_posts';
  static const String _blockedUsersKey = 'blocked_users';

  // 获取已屏蔽的帖子ID列表
  static Future<List<String>> getBlockedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_blockedPostsKey) ?? [];
  }

  // 屏蔽帖子
  static Future<void> blockPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedPosts = await getBlockedPosts();
    
    if (!blockedPosts.contains(postId)) {
      blockedPosts.add(postId);
      await prefs.setStringList(_blockedPostsKey, blockedPosts);
      print('Blocked post: $postId');
    }
  }

  // 取消屏蔽帖子
  static Future<void> unblockPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedPosts = await getBlockedPosts();
    
    if (blockedPosts.contains(postId)) {
      blockedPosts.remove(postId);
      await prefs.setStringList(_blockedPostsKey, blockedPosts);
      print('Unblocked post: $postId');
    }
  }

  // 检查帖子是否被屏蔽
  static Future<bool> isPostBlocked(String postId) async {
    final blockedPosts = await getBlockedPosts();
    return blockedPosts.contains(postId);
  }

  // 过滤已屏蔽的帖子
  static Future<List<T>> filterBlockedPosts<T>(
    List<T> posts,
    String Function(T) getPostId,
  ) async {
    final blockedPosts = await getBlockedPosts();
    return posts.where((post) => !blockedPosts.contains(getPostId(post))).toList();
  }

  // ========== 用户屏蔽功能 ==========

  // 获取已屏蔽的用户ID列表
  static Future<List<String>> getBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_blockedUsersKey) ?? [];
  }

  // 屏蔽用户
  static Future<void> blockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedUsers = await getBlockedUsers();
    
    if (!blockedUsers.contains(userId)) {
      blockedUsers.add(userId);
      await prefs.setStringList(_blockedUsersKey, blockedUsers);
      print('Blocked user: $userId');
    }
  }

  // 取消屏蔽用户
  static Future<void> unblockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedUsers = await getBlockedUsers();
    
    if (blockedUsers.contains(userId)) {
      blockedUsers.remove(userId);
      await prefs.setStringList(_blockedUsersKey, blockedUsers);
      print('Unblocked user: $userId');
    }
  }

  // 检查用户是否被屏蔽
  static Future<bool> isUserBlocked(String userId) async {
    final blockedUsers = await getBlockedUsers();
    return blockedUsers.contains(userId);
  }

  // 过滤已屏蔽用户的内容
  static Future<List<T>> filterBlockedUserContent<T>(
    List<T> items,
    String Function(T) getUserId,
  ) async {
    final blockedUsers = await getBlockedUsers();
    return items.where((item) => !blockedUsers.contains(getUserId(item))).toList();
  }
} 