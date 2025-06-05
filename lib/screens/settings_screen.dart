import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'feedback_screen.dart';
import 'user_agreement_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_us_screen.dart';
import 'my_reports_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 设置状态栏为黑色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            '设置',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // 功能设置分组
            _buildSectionTitle('功能设置'),
            SizedBox(height: 16),
            _buildSettingItem(
              context,
              icon: Icons.flag_outlined,
              title: '我的举报',
              subtitle: '查看举报记录和处理状态',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyReportsScreen()),
              ),
            ),
            SizedBox(height: 12),
            _buildSettingItem(
              context,
              icon: Icons.feedback_outlined,
              title: '意见反馈',
              subtitle: '告诉我们您的建议',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              ),
            ),
            
            SizedBox(height: 32),
            
            // 法律协议分组
            _buildSectionTitle('法律协议'),
            SizedBox(height: 16),
            _buildSettingItem(
              context,
              icon: Icons.description_outlined,
              title: '用户协议',
              subtitle: '查看用户服务协议',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserAgreementScreen()),
              ),
            ),
            SizedBox(height: 12),
            _buildSettingItem(
              context,
              icon: Icons.security_outlined,
              title: '隐私政策',
              subtitle: '了解我们的隐私保护',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              ),
            ),
            
            SizedBox(height: 32),
            
            // 关于应用分组
            _buildSectionTitle('关于应用'),
            SizedBox(height: 16),
            _buildSettingItem(
              context,
              icon: Icons.info_outline,
              title: '关于我们',
              subtitle: '了解心声日记',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsScreen()),
              ),
            ),
            
            SizedBox(height: 40),
            
            // 版本信息
            _buildVersionInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: AppColors.primary,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            '心声日记',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '记录每一刻心情',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
} 