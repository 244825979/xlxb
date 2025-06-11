import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../services/apple_signin_service.dart';
import 'recharge_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  @override
  _AccountManagementScreenState createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  static const String _coinsKey = 'user_coins';
  static const String _vipStatusKey = 'user_vip_status';
  
  Map<String, dynamic>? _appleUserInfo;
  bool _isLoading = false;
  bool _isAppleSignedIn = false;
  int _coins = 0;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 加载用户数据
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // 加载Apple登录状态
      _isAppleSignedIn = await AppleSignInService.isAppleSignedIn();
      if (_isAppleSignedIn) {
        _appleUserInfo = await AppleSignInService.getCurrentUser();
        
        // 检查Apple登录凭据状态
        final credentialState = await AppleSignInService.checkCredentialState();
        if (!credentialState['success']) {
          debugPrint('Apple credential state check failed: ${credentialState['message']}');
          if (credentialState['state'] == 'revoked' || credentialState['state'] == 'notFound') {
            await _handleSignOut();
          }
        } else {
          // 加载用户金币和VIP状态
          await _loadUserStatus();
        }
      } else {
        // 未登录时重置状态
        await _resetUserStatus();
      }
    } catch (e) {
      debugPrint('Load user data error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 加载用户状态（金币和VIP）
  Future<void> _loadUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdentifier = _appleUserInfo?['userIdentifier'] as String?;
      
      if (userIdentifier != null) {
        // 读取金币数量
        final coins = prefs.getInt('user_coins_$userIdentifier') ?? 0;
        
        // 读取VIP状态
        bool isVip = prefs.getBool('user_vip_status_$userIdentifier') ?? false;
        
        // 如果VIP状态为true，检查是否过期
        if (isVip) {
          final expireTime = prefs.getInt('user_vip_expire_time_$userIdentifier') ?? 0;
          if (expireTime > 0) {
            final expireDateTime = DateTime.fromMillisecondsSinceEpoch(expireTime);
            if (DateTime.now().isAfter(expireDateTime)) {
              // VIP已过期，重置状态
              isVip = false;
              await prefs.setBool('user_vip_status_$userIdentifier', false);
              debugPrint('VIP已过期，自动重置状态');
            }
          }
        }
        
        setState(() {
          _coins = coins;
          _isVip = isVip;
        });
        
        debugPrint('加载用户状态 - 金币: $_coins, VIP: $_isVip');
      }
    } catch (e) {
      debugPrint('Load user status error: $e');
    }
  }

  // 重置用户状态
  Future<void> _resetUserStatus() async {
    setState(() {
      _coins = 0;
      _isVip = false;
      _appleUserInfo = null;
    });
  }

  // 更新用户金币
  Future<void> _updateUserCoins(int newCoins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdentifier = _appleUserInfo?['userIdentifier'] as String?;
      
      if (userIdentifier != null) {
        await prefs.setInt('user_coins_$userIdentifier', newCoins);
        setState(() {
          _coins = newCoins;
        });
      }
    } catch (e) {
      debugPrint('Update user coins error: $e');
    }
  }

  // 更新VIP状态
  Future<void> _updateVipStatus(bool isVip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdentifier = _appleUserInfo?['userIdentifier'] as String?;
      
      if (userIdentifier != null) {
        await prefs.setBool('user_vip_status_$userIdentifier', isVip);
        setState(() {
          _isVip = isVip;
        });
      }
    } catch (e) {
      debugPrint('Update VIP status error: $e');
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await AppleSignInService.signInWithApple();
      
      if (result['success']) {
        setState(() {
          _isAppleSignedIn = true;
          _appleUserInfo = result['userInfo'];
        });
        // 登录成功后加载用户状态
        await _loadUserStatus();
        _showSuccessSnackBar(result['message']);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Apple登录失败');
      }
    } catch (e) {
      _showErrorSnackBar('Apple登录失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    try {
      final result = await AppleSignInService.signOutApple();
      if (result['success']) {
        await _resetUserStatus();
        setState(() {
          _isAppleSignedIn = false;
        });
        _showSuccessSnackBar(result['message']);
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('解除绑定失败: $e');
    }
  }

  // 处理充值页面返回
  Future<void> _handleRecharge() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => RechargeScreen()),
    );
    
    // 充值页面返回后，重新加载用户状态以确保数据同步
    await _loadUserStatus();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF0F5),
            Color(0xFFFFF8FA),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '账户管理',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAccountCard(),
                  SizedBox(height: 24),
                  _buildAppleSignInCard(),
                  SizedBox(height: 24),
                  _buildRechargeButton(),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  '金币余额',
                  _isAppleSignedIn ? _formatNumber(_coins) : '0',
                  Icons.monetization_on,
                  Colors.orange
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'VIP状态',
                  _isAppleSignedIn ? (_isVip ? '已开通' : '未开通') : '未开通',
                  Icons.star,
                  _isVip ? Colors.purple : Colors.grey
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleSignInCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.apple,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apple 登录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '安全便捷的登录与支付方式',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_isAppleSignedIn) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.green.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '已绑定Apple账户',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (_appleUserInfo != null) ...[
                    Text(
                      '用户名: ${AppleSignInService.getUserDisplayName(_appleUserInfo)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    if (AppleSignInService.getUserEmail(_appleUserInfo).isNotEmpty)
                      Text(
                        '邮箱: ${AppleSignInService.getUserEmail(_appleUserInfo)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await AppleSignInService.signOutApple();
                  if (result['success']) {
                    setState(() {
                      _isAppleSignedIn = false;
                      _appleUserInfo = null;
                    });
                    _showSuccessSnackBar(result['message']);
                  } else {
                    _showErrorSnackBar(result['message']);
                  }
                },
                icon: Icon(Icons.logout, size: 18),
                label: Text('解除绑定'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '绑定Apple账户后可享受以下功能：',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem('🔐', '安全快速登录'),
                  _buildFeatureItem('💳', 'Apple Pay便捷支付'),
                  _buildFeatureItem('☁️', '数据云端同步'),
                  _buildFeatureItem('🔄', '多设备账户同步'),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleAppleSignIn,
                icon: Icon(Icons.apple, size: 20),
                label: Text('使用Apple登录绑定'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shadowColor: AppColors.textPrimary.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      double value = number / 1000.0;
      return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}K';
    }
    return number.toString();
  }

  Widget _buildRechargeButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isAppleSignedIn ? _handleRecharge : null,
        icon: Icon(Icons.add_card, color: Colors.white, size: 24),
        label: Text(
          _isAppleSignedIn ? '立即充值' : '请先登录',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
} 