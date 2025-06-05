import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_assets.dart';

class AboutUsScreen extends StatelessWidget {
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
            '关于我们',
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
          child: Column(
            children: [
              // Logo和应用名称
              Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.softShadow],
                ),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          AppAssets.logo,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    Text(
                      '心声日记',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      'Voice Diary',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // 应用介绍
              _buildInfoCard(
                '应用介绍',
                '心声日记是一款专注于心理健康的语音日记应用。我们相信每个人的内心声音都值得被记录和珍藏。通过语音记录、情感分析、心情追踪等功能，帮助用户更好地了解自己，管理情绪，提升心理健康水平。',
                Icons.description_outlined,
              ),
              
              SizedBox(height: 16),
              
              // 核心功能
              _buildInfoCard(
                '核心功能',
                '• 语音日记记录\n'
                '• 智能情感分析\n'
                '• 心情指数追踪\n'
                '• 个性化建议\n'
                '• 社区分享广场\n'
                '• 精选心情语录\n'
                '• 数据统计分析\n'
                '• 隐私安全保护',
                Icons.star_outline,
              ),
              
              SizedBox(height: 16),
              
              // 设计理念
              _buildInfoCard(
                '设计理念',
                '我们秉承"简约而不简单"的设计理念，以用户体验为中心，打造温暖治愈的视觉风格。每一个细节都经过精心设计，只为给您带来最舒适的使用体验。',
                Icons.palette_outlined,
              ),
              
              SizedBox(height: 16),
              
              // 团队介绍
              _buildInfoCard(
                '开发团队',
                '我们是一支专注于心理健康领域的年轻团队，由资深开发工程师、UI设计师和心理学专家组成。我们致力于用技术的力量，为更多人的心理健康保驾护航。',
                Icons.group_outlined,
              ),
              
              SizedBox(height: 24),
              
              // 感谢
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
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
                      '感谢您的使用',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      '愿心声日记陪伴您的每一天，记录美好，治愈心灵',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 