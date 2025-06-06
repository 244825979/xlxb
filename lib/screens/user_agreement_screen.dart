import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class UserAgreementScreen extends StatelessWidget {
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
            '用户协议',
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Center(
                  child: Text(
                    '心声日记用户服务协议',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                
                SizedBox(height: 8),
                
                Center(
                  child: Text(
                    '更新日期：2024年1月1日',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // 前言
                _buildSection(
                  '前言',
                  '欢迎您使用心声日记！本协议是您与心声日记之间关于您使用心声日记服务所订立的协议。请您仔细阅读本协议，确保充分理解本协议中各条款。',
                ),
                
                // 服务内容
                _buildSection(
                  '1. 服务内容',
                  '心声日记是一款专注于情感记录和心理健康的移动应用，为用户提供：\n\n'
                  '• 语音日记记录功能\n'
                  '• 心情指数跟踪\n'
                  '• 情感分析和建议\n'
                  '• 社区广场分享\n'
                  '• 心情语录收藏\n'
                  '• 数据统计和回顾',
                ),
                
                // 用户权利义务
                _buildSection(
                  '2. 用户权利与义务',
                  '2.1 用户权利\n'
                  '• 免费使用基础功能\n'
                  '• 数据隐私保护\n'
                  '• 客服支持服务\n\n'
                  '2.2 用户义务\n'
                  '• 提供真实信息\n'
                  '• 遵守法律法规\n'
                  '• 不发布违法有害内容\n'
                  '• 保护账号安全\n\n'
                  '2.3 内容责任与平台政策\n'
                  '• 用户须对自身发布内容负责，平台对违规内容采取零容忍政策，包括但不限于删除内容、账号封禁等措施\n'
                  '• 屏蔽功能可限制其他用户的互动行为，但无法完全隔离第三方信息',
                ),
                
                // 隐私保护
                _buildSection(
                  '3. 隐私保护',
                  '我们高度重视用户隐私保护：\n\n'
                  '• 您的语音记录仅存储在本地设备\n'
                  '• 心情数据采用加密存储\n'
                  '• 不会泄露您的个人信息\n'
                  '• 匿名数据分析用于改进服务',
                ),
                
                // 免责声明
                _buildSection(
                  '4. 免责声明',
                  '• 本应用提供的建议仅供参考，不构成专业医疗意见\n'
                  '• 如需专业心理咨询，请寻求专业医师帮助\n'
                  '• 用户应为自己的行为承担责任\n'
                  '• 不可抗力因素导致的服务中断不承担责任',
                ),
                
                // 协议变更
                _buildSection(
                  '5. 协议变更',
                  '我们可能会根据法律法规变化或业务发展需要修改本协议。修改后的协议将在应用内公布，继续使用服务即表示您同意修改后的协议。',
                ),
                
                SizedBox(height: 32),
                
                // 同意按钮
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '我已阅读并同意',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
} 