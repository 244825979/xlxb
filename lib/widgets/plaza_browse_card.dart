import 'package:flutter/material.dart';
import 'dart:io';
import '../models/plaza_post.dart';
import '../constants/app_colors.dart';
import '../screens/post_detail_screen.dart';
import '../screens/image_view_screen.dart';

class PlazaBrowseCard extends StatelessWidget {
  final PlazaPost post;
  final VoidCallback? onLike;

  const PlazaBrowseCard({
    Key? key,
    required this.post,
    this.onLike,
  }) : super(key: key);

  // 构建图片显示组件
  Widget _buildImageWidget(String imagePath) {
    // 检查是否为本地文件路径
    if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
      // 本地文件
      return Image.file(
        File(imagePath.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.textLight.withOpacity(0.3),
            child: Icon(
              Icons.broken_image,
              color: AppColors.textLight,
              size: 32,
            ),
          );
        },
      );
    } else {
      // Asset图片
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.textLight.withOpacity(0.3),
            child: Icon(
              Icons.broken_image,
              color: AppColors.textLight,
              size: 32,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.softShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 让Column根据内容自适应高度
          children: [
            // 头部：用户信息
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(post.userAvatar),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.formattedCreatedAt,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 图片内容（如果有）
            if (post.hasImage) ...[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewScreen(
                        imageUrl: post.imageUrl!,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 4/3, // 设置为4:3比例
                    child: _buildImageWidget(post.imageUrl!),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
            
            // 文字内容 - 移除Expanded，让文字自然显示
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                post.content,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
                // 移除maxLines限制，让文字完全显示
              ),
            ),
            
            SizedBox(height: 8), // 文字和底部按钮之间的间距
            
            // 底部：互动区域
            Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onLike,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: post.isLiked ? Colors.red : AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '喜欢',
                          style: TextStyle(
                            color: post.isLiked ? Colors.red : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      if (post.commentCount > 0) ...[
                        SizedBox(width: 2),
                        Text(
                          '${post.commentCount}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 