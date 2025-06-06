import 'package:flutter/material.dart';
import 'dart:io';
import '../models/plaza_post.dart';
import '../constants/app_colors.dart';
import '../screens/post_detail_screen.dart';
import '../screens/image_view_screen.dart';
import '../widgets/report_dialog.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';

class PlazaBrowseCard extends StatelessWidget {
  final PlazaPost post;
  final VoidCallback? onLike;
  final VoidCallback? onBlock;

  const PlazaBrowseCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onBlock,
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
                        Row(
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
                            // 审核中标识
                            if (post.isUnderReview && UserService.isCurrentUser(post.userId)) ...[
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  '审核中',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
            Container(
              margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // 主要互动按钮
                  Row(
                    children: [
                      // 喜欢按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: onLike,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: post.isLiked ? Colors.red.withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: post.isLiked ? Colors.red : AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '喜欢',
                                  style: TextStyle(
                                    color: post.isLiked ? Colors.red : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // 评论按钮
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(post: post),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  post.commentCount > 0 ? '${post.commentCount}' : '评论',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // 管理功能按钮 - 只对非当前用户的内容显示
                  if (!UserService.isCurrentUser(post.userId)) ...[
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      height: 0.5,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    Row(
                      children: [
                        // 屏蔽按钮
                        if (onBlock != null)
                          Expanded(
                            child: GestureDetector(
                              onTap: onBlock,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.block,
                                      size: 16,
                                      color: Colors.orange.withOpacity(0.7),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '屏蔽',
                                      style: TextStyle(
                                        color: Colors.orange.withOpacity(0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // 分隔线
                        if (onBlock != null)
                          Container(
                            height: 12,
                            width: 0.5,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        // 举报按钮
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showReportDialog(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    size: 16,
                                    color: Colors.red.withOpacity(0.7),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    '举报',
                                    style: TextStyle(
                                      color: Colors.red.withOpacity(0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final reportService = ReportService();
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetContent: post.content,
        targetType: 'post',
        targetId: reportService.generateTargetId(post.content),
      ),
    );
  }
} 