import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
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
            '隐私政策',
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
                    '心声日记隐私政策',
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
                    '生效日期：2024年1月1日',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // 概述
                _buildSection(
                  '概述',
                  '心声日记深知个人信息对您的重要性，我们将按照法律法规要求，采用相应的安全保护措施，保护您的个人信息安全可控。',
                ),
                
                // 收集信息
                _buildSection(
                  '1. 我们收集的信息',
                  '1.1 您主动提供的信息\n'
                  '• 语音日记内容（仅本地存储）\n'
                  '• 心情指数记录\n'
                  '• 文字日记内容\n'
                  '• 个人设置偏好\n\n'
                  '1.2 自动收集的信息\n'
                  '• 设备信息（型号、系统版本）\n'
                  '• 应用使用统计（匿名）\n'
                  '• 错误日志（用于改进服务）',
                ),
                
                // 信息使用
                _buildSection(
                  '2. 信息使用目的',
                  '我们收集您的信息用于：\n\n'
                  '• 提供核心日记功能\n'
                  '• 生成心情分析报告\n'
                  '• 改进应用性能和体验\n'
                  '• 提供个性化建议\n'
                  '• 技术支持和客户服务\n'
                  '• 保障应用安全性',
                ),
                
                // 信息保护
                _buildSection(
                  '3. 信息保护措施',
                  '3.1 技术保护\n'
                  '• 语音数据采用端到端加密\n'
                  '• 敏感数据本地存储\n'
                  '• 定期安全漏洞扫描\n'
                  '• 访问权限严格控制\n\n'
                  '3.2 管理保护\n'
                  '• 员工隐私培训\n'
                  '• 数据访问审计\n'
                  '• 第三方安全评估',
                ),
                
                // 信息共享
                _buildSection(
                  '4. 信息共享',
                  '我们承诺不会将您的个人信息出售、出租或交易给第三方。仅在以下情况下可能共享：\n\n'
                  '• 获得您的明确同意\n'
                  '• 法律法规要求\n'
                  '• 保护用户或公众安全\n'
                  '• 匿名化数据用于研究（无法识别个人身份）',
                ),
                
                // 用户权利
                _buildSection(
                  '5. 您的权利',
                  '• 访问权：查看我们持有的您的信息\n'
                  '• 更正权：要求更正不准确的信息\n'
                  '• 删除权：要求删除您的个人信息\n'
                  '• 限制权：限制我们处理您的信息\n'
                  '• 数据导出：以可读格式获取您的数据',
                ),
                
                // Cookie
                _buildSection(
                  '6. Cookies 和类似技术',
                  '我们可能使用Cookies和类似技术来：\n\n'
                  '• 记住您的偏好设置\n'
                  '• 分析应用使用情况\n'
                  '• 改善用户体验\n\n'
                  '您可以通过设备设置管理Cookies。',
                ),
                
                // 未成年人
                _buildSection(
                  '7. 未成年人保护',
                  '我们非常重视未成年人的隐私保护。如果您是18岁以下的未成年人，请在监护人陪同下阅读本政策，并在监护人同意后使用我们的服务。',
                ),
                
                // 政策更新
                _buildSection(
                  '8. 隐私政策更新',
                  '我们可能会不时更新本隐私政策。重大变更时，我们会通过应用内通知等方式告知您。继续使用服务表示您同意更新后的政策。',
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
                      '我已了解隐私政策',
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