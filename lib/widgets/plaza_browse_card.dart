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
          mainAxisSize: MainAxisSize.min,
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
                    aspectRatio: 4/3,
                    child: _buildImageWidget(post.imageUrl!),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
            
            // 文字内容
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                post.content,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            
            SizedBox(height: 8),
            
            // 底部：互动区域
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 375;
                final cardWidth = constraints.maxWidth;
                final isVeryNarrowCard = cardWidth < 140; // 极窄卡片
                final isNarrowCard = cardWidth < 160; // 窄卡片
                
                // 动态计算字体大小和间距 - 更激进的缩小策略
                double getFontSize() {
                  if (cardWidth < 120) return 7; // 极小卡片
                  if (cardWidth < 140) return 8; // 很小卡片
                  if (cardWidth < 160) return 9; // 小卡片
                  if (cardWidth < 180) return 10; // 中小卡片
                  if (isSmallScreen) return 11;
                  return 13;
                }
                
                double getIconSize() {
                  if (cardWidth < 120) return 12; // 极小图标
                  if (cardWidth < 140) return 13; // 很小图标
                  if (cardWidth < 160) return 14; // 小图标
                  if (cardWidth < 180) return 15; // 中小图标
                  if (isNarrowCard) return 16;
                  return 18;
                }
                
                double getSpacing() {
                  if (cardWidth < 120) return 0.5; // 几乎无间距
                  if (cardWidth < 140) return 1; // 极小间距
                  if (cardWidth < 160) return 1.5; // 很小间距
                  if (cardWidth < 180) return 2; // 小间距
                  return 4;
                }
                
                double getPadding() {
                  if (cardWidth < 120) return 2; // 极小内边距
                  if (cardWidth < 140) return 3; // 很小内边距
                  if (cardWidth < 160) return 4; // 小内边距
                  if (cardWidth < 180) return 5; // 中小内边距
                  if (isNarrowCard) return 6;
                  return 8;
                }
                
                double getHorizontalPadding() {
                  if (cardWidth < 120) return 1; // 极小水平内边距
                  if (cardWidth < 140) return 2; // 很小水平内边距
                  if (cardWidth < 160) return 3; // 小水平内边距
                  if (cardWidth < 180) return 4; // 中小水平内边距
                  return isNarrowCard ? 4 : 8;
                }
                
                return Container(
                  margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  padding: EdgeInsets.all(getPadding()),
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
                                padding: EdgeInsets.symmetric(
                                  vertical: (getPadding() - 2).clamp(1, 8), 
                                  horizontal: getHorizontalPadding(),
                                ),
                                decoration: BoxDecoration(
                                  color: post.isLiked ? Colors.red.withOpacity(0.08) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                                      size: getIconSize(),
                                      color: post.isLiked ? Colors.red : AppColors.textSecondary,
                                    ),
                                    SizedBox(width: getSpacing()),
                                    Flexible(
                                      child: Text(
                                        '喜欢',
                                        style: TextStyle(
                                          color: post.isLiked ? Colors.red : AppColors.textSecondary,
                                          fontSize: getFontSize(),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: getSpacing() * 2),
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
                                padding: EdgeInsets.symmetric(
                                  vertical: (getPadding() - 2).clamp(1, 8), 
                                  horizontal: getHorizontalPadding(),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: getIconSize(),
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(width: getSpacing()),
                                    Flexible(
                                      child: Text(
                                        post.commentCount > 0 ? '${post.commentCount}' : '评论',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: getFontSize(),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: (getPadding() - 3).clamp(1, 6), 
                                      horizontal: (getHorizontalPadding() * 0.75).clamp(1, 6),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.block,
                                          size: getIconSize() - 2,
                                          color: Colors.orange.withOpacity(0.7),
                                        ),
                                        SizedBox(width: getSpacing()),
                                        Flexible(
                                          child: Text(
                                            '屏蔽',
                                            style: TextStyle(
                                              color: Colors.orange.withOpacity(0.7),
                                              fontSize: (getFontSize() - 1).clamp(6, 12),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // 举报按钮
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showReportDialog(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: (getPadding() - 3).clamp(1, 6), 
                                    horizontal: (getHorizontalPadding() * 0.75).clamp(1, 6),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: getIconSize() - 2,
                                        color: Colors.red.withOpacity(0.7),
                                      ),
                                      SizedBox(width: getSpacing()),
                                      Flexible(
                                        child: Text(
                                          '举报',
                                          style: TextStyle(
                                            color: Colors.red.withOpacity(0.7),
                                            fontSize: (getFontSize() - 1).clamp(6, 12),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
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
                );
              },
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