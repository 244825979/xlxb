import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppleSignInService {
  static const String _appleUserKey = 'apple_user_info';
  static const String _appleAuthKey = 'apple_auth_info';

  // Apple用户信息模型
  static Map<String, dynamic>? _currentUser;

  // 检查是否已经绑定Apple账户
  static Future<bool> isAppleSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfo = prefs.getString(_appleUserKey);
      return userInfo != null && userInfo.isNotEmpty;
    } catch (e) {
      debugPrint('Check Apple sign in status error: $e');
      return false;
    }
  }

  // 获取当前绑定的Apple用户信息
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString(_appleUserKey);
      
      if (userInfoString != null) {
        _currentUser = json.decode(userInfoString);
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Get current Apple user error: $e');
    }
    
    return null;
  }

  // 执行Apple登录绑定
  static Future<Map<String, dynamic>> signInWithApple() async {
    try {
      // 检查Apple登录是否可用
      if (!await SignInWithApple.isAvailable()) {
        throw Exception('Apple登录在此设备上不可用');
      }

      // 执行Apple登录
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'your.app.bundle.id', // 需要替换为实际的客户端ID
          redirectUri: Uri.parse('https://your-app.com/auth/callback'),
        ),
      );

      // 构建用户信息
      final userInfo = {
        'userIdentifier': credential.userIdentifier,
        'email': credential.email ?? '',
        'givenName': credential.givenName ?? '',
        'familyName': credential.familyName ?? '',
        'fullName': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
        'bindTime': DateTime.now().millisecondsSinceEpoch,
        'authorizationCode': credential.authorizationCode,
        'identityToken': credential.identityToken,
      };

      // 保存用户信息
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appleUserKey, json.encode(userInfo));
      await prefs.setString(_appleAuthKey, json.encode({
        'authorizationCode': credential.authorizationCode,
        'identityToken': credential.identityToken,
        'userIdentifier': credential.userIdentifier,
      }));

      _currentUser = userInfo;

      return {
        'success': true,
        'userInfo': userInfo,
        'message': 'Apple登录绑定成功',
      };
    } catch (e) {
      debugPrint('Apple sign in error: $e');
      
      String errorMessage = 'Apple登录失败';
      if (e.toString().contains('canceled')) {
        errorMessage = '用户取消了Apple登录';
      } else if (e.toString().contains('not available')) {
        errorMessage = 'Apple登录在此设备上不可用';
      } else if (e.toString().contains('network')) {
        errorMessage = '网络连接失败，请检查网络设置';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // 解除Apple登录绑定
  static Future<Map<String, dynamic>> signOutApple() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_appleUserKey);
      await prefs.remove(_appleAuthKey);
      
      _currentUser = null;

      return {
        'success': true,
        'message': 'Apple账户已解除绑定',
      };
    } catch (e) {
      debugPrint('Apple sign out error: $e');
      return {
        'success': false,
        'message': '解除绑定失败',
      };
    }
  }

  // 获取用户显示名称
  static String getUserDisplayName(Map<String, dynamic>? userInfo) {
    if (userInfo == null) return '';
    
    final fullName = userInfo['fullName'] as String? ?? '';
    final email = userInfo['email'] as String? ?? '';
    
    if (fullName.isNotEmpty) {
      return fullName;
    } else if (email.isNotEmpty) {
      return email.split('@').first;
    } else {
      return 'Apple用户';
    }
  }

  // 获取用户邮箱
  static String getUserEmail(Map<String, dynamic>? userInfo) {
    if (userInfo == null) return '';
    return userInfo['email'] as String? ?? '';
  }

  // 验证Apple登录状态
  static Future<bool> validateAppleSignIn() async {
    try {
      final userInfo = await getCurrentUser();
      if (userInfo == null) return false;

      // 这里可以添加更多的验证逻辑，比如检查token是否过期
      final bindTime = userInfo['bindTime'] as int?;
      if (bindTime == null) return false;

      // 检查绑定时间是否超过一定期限（比如30天）
      final now = DateTime.now().millisecondsSinceEpoch;
      final daysDiff = (now - bindTime) / (1000 * 60 * 60 * 24);
      
      return daysDiff < 30; // 30天内有效
    } catch (e) {
      debugPrint('Validate Apple sign in error: $e');
      return false;
    }
  }
} 