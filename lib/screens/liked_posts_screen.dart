import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_assets.dart';
import '../providers/profile_provider.dart';
import '../models/plaza_post.dart';
import '../models/voice_record.dart';
import '../screens/post_detail_screen.dart';

class LikedPostsScreen extends StatelessWidget {
  // 将VoiceRecord转换为PlazaPost
  PlazaPost _convertToPlazaPost(VoiceRecord record) {
    return PlazaPost(
      id: record.id,
      userId: 'user_${record.id}',
      userName: record.title,
      userAvatar: record.userAvatar ?? AppAssets.defaultAvatar,
      content: record.description ?? '',
      imageUrl: record.imageUrl,
      createdAt: record.timestamp,
      isVirtual: false,
      moodScore: record.moodScore ?? 5.0,
      isLiked: record.isFavorite,
    );
  }

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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '喜欢的动态',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            final likedPosts = provider.userProfile?.favoriteRecords ?? [];
            
            if (likedPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '还没有喜欢的动态',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '浏览广场，为喜欢的动态点赞吧',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: likedPosts.length,
              itemBuilder: (context, index) {
                final record = likedPosts[index];
                final post = _convertToPlazaPost(record);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [AppColors.softShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户信息
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(post.userAvatar),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.userName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    post.formattedCreatedAt,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        // 内容
                        Text(
                          post.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        
                        // 图片内容
                        if (post.hasImage) ...[
                          SizedBox(height: 12),
                          AspectRatio(
                            aspectRatio: 4/3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(post.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                        
                        // 互动区域
                        SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => provider.toggleFavorite(record),
                              child: Row(
                                children: [
                                  Icon(
                                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 20,
                                    color: post.isLiked ? Colors.red : AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '喜欢',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: post.isLiked ? Colors.red : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '评论${post.commentCount > 0 ? '(${post.commentCount})' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 