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
        nonce: 'apple_signin_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 构建用户信息
      final displayName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      final userInfo = {
        'userIdentifier': credential.userIdentifier,
        'email': credential.email ?? '',
        'givenName': credential.givenName ?? '',
        'familyName': credential.familyName ?? '',
        'fullName': displayName.isEmpty ? 'Apple用户' : displayName,
        'bindTime': DateTime.now().millisecondsSinceEpoch,
        'authorizationCode': credential.authorizationCode,
        'identityToken': credential.identityToken,
        'state': credential.state,
      };

      // 保存用户信息
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appleUserKey, json.encode(userInfo));
      await prefs.setString(_appleAuthKey, json.encode({
        'authorizationCode': credential.authorizationCode,
        'identityToken': credential.identityToken,
        'userIdentifier': credential.userIdentifier,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));

      _currentUser = userInfo;

      return {
        'success': true,
        'userInfo': userInfo,
        'message': 'Apple登录绑定成功！欢迎使用',
      };
    } catch (e) {
      String errorMessage = 'Apple登录失败';
      
      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        errorMessage = '用户取消了Apple登录';
      } else if (e.toString().contains('not available')) {
        errorMessage = 'Apple登录在此设备上不可用';
      } else if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = '网络连接失败，请检查网络设置';
      } else if (e.toString().contains('invalidResponse')) {
        errorMessage = '登录响应无效，请重试';
      } else if (e.toString().contains('1000')) {
        errorMessage = 'Apple登录配置错误，请确保已在设备上登录Apple ID';
      } else if (e.toString().contains('unknown')) {
        errorMessage = '未知错误，请稍后重试';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': e.toString(),
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
    final givenName = userInfo['givenName'] as String? ?? '';
    final email = userInfo['email'] as String? ?? '';
    
    if (fullName.isNotEmpty && fullName != 'Apple用户') {
      return fullName;
    } else if (givenName.isNotEmpty) {
      return givenName;
    } else if (email.isNotEmpty) {
      final username = email.split('@').first;
      return username.isNotEmpty ? username : 'Apple用户';
    } else {
      return 'Apple用户';
    }
  }

  // 获取用户邮箱
  static String getUserEmail(Map<String, dynamic>? userInfo) {
    if (userInfo == null) return '';
    return userInfo['email'] as String? ?? '';
  }

  // 检查Apple登录授权状态
  static Future<Map<String, dynamic>> checkCredentialState() async {
    try {
      final userInfo = await getCurrentUser();
      if (userInfo == null) {
        return {
          'success': false,
          'message': '未找到Apple登录信息',
        };
      }

      final userIdentifier = userInfo['userIdentifier'] as String?;
      if (userIdentifier == null) {
        return {
          'success': false,
          'message': '用户标识符无效',
        };
      }

      // 检查凭据状态
      final credentialState = await SignInWithApple.getCredentialState(userIdentifier);
      
      switch (credentialState) {
        case CredentialState.authorized:
          return {
            'success': true,
            'message': 'Apple登录状态正常',
            'state': 'authorized',
          };
        case CredentialState.revoked:
          return {
            'success': false,
            'message': 'Apple登录已被撤销',
            'state': 'revoked',
          };
        case CredentialState.notFound:
          return {
            'success': false,
            'message': '未找到Apple登录凭据',
            'state': 'notFound',
          };
        default:
          return {
            'success': false,
            'message': '未知的凭据状态',
            'state': 'unknown',
          };
      }
    } catch (e) {
      debugPrint('Check credential state error: $e');
      return {
        'success': false,
        'message': '检查登录状态失败',
        'error': e.toString(),
      };
    }
  }
} 