import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'constants/app_colors.dart';

class AppleSignInTestRunner extends StatefulWidget {
  @override
  _AppleSignInTestRunnerState createState() => _AppleSignInTestRunnerState();
}

class _AppleSignInTestRunnerState extends State<AppleSignInTestRunner> {
  String _status = '准备测试Apple登录...';
  bool _isLoading = false;
  List<String> _logs = [];
  bool _hasSuccess = false;

  @override
  void initState() {
    super.initState();
    _addLog('🚀 Apple登录测试器启动');
    _addLog('📱 设备: iPhone');
    _addLog('🔧 Xcode配置已更新');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $message');
    });
    debugPrint('AppleSignInTest: $message');
  }

  void _updateStatus(String status) {
    setState(() {
      _status = status;
    });
    _addLog('📊 状态: $status');
  }

  Future<void> _testAppleSignInWithRetry() async {
    setState(() {
      _isLoading = true;
      _hasSuccess = false;
      _logs.clear();
    });

    _addLog('🚀 开始Apple登录测试（配置后）');
    
    try {
      // 1. 检查基础可用性
      _updateStatus('检查Apple Sign In可用性...');
      final isAvailable = await SignInWithApple.isAvailable();
      _addLog('1️⃣ 可用性检查: ${isAvailable ? "✅ 可用" : "❌ 不可用"}');
      
      if (!isAvailable) {
        _addLog('❌ Apple Sign In不可用，无法继续测试');
        _updateStatus('测试失败：Apple Sign In不可用');
        return;
      }

      // 2. 尝试登录（最新配置）
      _updateStatus('尝试Apple登录（使用最新Xcode配置）...');
      _addLog('2️⃣ 尝试Apple登录...');
      
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: 'com.aoyou.xinbo1',
            redirectUri: Uri.parse('https://your-redirect-url.com/'),
          ),
        );

        // 3. 成功处理
        _addLog('✅ Apple登录成功！');
        _addLog('👤 用户标识符: ${credential.userIdentifier ?? "未提供"}');
        _addLog('📧 邮箱: ${credential.email ?? "未提供"}');
        _addLog('👨‍💼 姓名: ${credential.givenName ?? ""} ${credential.familyName ?? ""}');
        _addLog('🔑 授权代码: ${credential.authorizationCode != null ? "已获取" : "未获取"}');
        _addLog('🎫 身份令牌: ${credential.identityToken != null ? "已获取" : "未获取"}');
        
        setState(() {
          _hasSuccess = true;
        });
        _updateStatus('✅ Apple登录测试成功！');
        
        // 显示成功对话框
        _showSuccessDialog(credential);

      } catch (e) {
        _addLog('❌ Apple登录失败: $e');
        
        if (e.toString().contains('1000')) {
          _addLog('🔍 错误分析: 这仍然是错误1000');
          _addLog('💡 可能的原因:');
          _addLog('   • 设备Apple ID状态问题');
          _addLog('   • 双重认证未启用');
          _addLog('   • Apple服务器临时问题');
          _addLog('   • 开发者配置仍需调整');
        } else if (e.toString().contains('canceled')) {
          _addLog('ℹ️ 用户取消了登录');
        } else {
          _addLog('🔍 其他错误: ${e.toString()}');
        }
        
        _updateStatus('❌ Apple登录失败');
        _showErrorDialog(e.toString());
      }

    } catch (e) {
      _addLog('❌ 测试过程中发生异常: $e');
      _updateStatus('测试异常');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(dynamic credentialOrUserInfo) {
    // 处理不同的输入类型
    String userId = '';
    String email = '';
    String name = '';
    
    if (credentialOrUserInfo is AuthorizationCredentialAppleID) {
      userId = credentialOrUserInfo.userIdentifier?.substring(0, 10) ?? "N/A";
      email = credentialOrUserInfo.email ?? "未提供";
      name = "${credentialOrUserInfo.givenName ?? ""} ${credentialOrUserInfo.familyName ?? ""}";
    } else if (credentialOrUserInfo is Map<String, dynamic>) {
      userId = credentialOrUserInfo['userIdentifier']?.toString().substring(0, 10) ?? "N/A";
      email = credentialOrUserInfo['email']?.toString() ?? "未提供";
      name = "${credentialOrUserInfo['givenName'] ?? ""} ${credentialOrUserInfo['familyName'] ?? ""}";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('登录成功！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎉 Apple登录配置成功！'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('用户信息:'),
                  SizedBox(height: 4),
                  Text('ID: ${userId}...'),
                  Text('邮箱: $email'),
                  Text('姓名: $name'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('太好了！'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('登录失败'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apple登录仍然失败'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                error,
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: 12),
            Text(
              '建议下一步:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '1. 确认设备已登录Apple ID\n2. 检查双重认证是否启用\n3. 尝试重启设备\n4. 检查网络连接',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('知道了'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _testAppleSignInWithRetry();
            },
            child: Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testMinimalAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    _addLog('🧪 执行最小化Apple登录测试...');
    
    try {
      // 最简单的Apple登录测试
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [], // 不请求任何额外权限
      );
      
      _addLog('✅ 最小化测试成功！');
      _addLog('🆔 获得用户标识符: ${credential.userIdentifier != null}');
      
      _showSuccessDialog(credential);
      
    } catch (e) {
      _addLog('❌ 最小化测试也失败: $e');
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apple登录测试器'),
        backgroundColor: _hasSuccess ? Colors.green : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // 状态显示
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: _hasSuccess 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.white.withOpacity(0.9),
              child: Row(
                children: [
                  if (_isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                  ],
                  if (_hasSuccess) ...[
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _hasSuccess ? Colors.green.shade700 : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 操作按钮
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testAppleSignInWithRetry,
                      icon: Icon(Icons.apple),
                      label: Text('测试Apple登录（配置后）'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testMinimalAppleSignIn,
                      icon: Icon(Icons.science),
                      label: Text('最小化测试'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _logs.clear();
                          _hasSuccess = false;
                        });
                      },
                      icon: Icon(Icons.clear),
                      label: Text('清除日志'),
                    ),
                  ),
                ],
              ),
            ),
            
            // 日志显示
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    Color textColor = Colors.green.shade300;
                    
                    if (log.contains('❌') || log.contains('失败')) {
                      textColor = Colors.red.shade300;
                    } else if (log.contains('✅') || log.contains('成功')) {
                      textColor = Colors.green.shade300;
                    } else if (log.contains('⚠️') || log.contains('警告')) {
                      textColor = Colors.yellow.shade300;
                    }
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: SelectableText(
                        log,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 