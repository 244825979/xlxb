import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_assets.dart';
import '../widgets/report_dialog.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../models/plaza_post.dart';

class PlazaPostItem extends StatelessWidget {
  final String id;
  final String userName;
  final String content;
  final DateTime timestamp;
  final double moodScore;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;
  final String? imageUrl;
  final String? userAvatar;
  final String? userId;
  final ReviewStatus? reviewStatus;

  const PlazaPostItem({
    Key? key,
    required this.id,
    required this.userName,
    required this.content,
    required this.timestamp,
    required this.moodScore,
    this.isFavorite = false,
    this.onFavoritePressed,
    this.imageUrl,
    this.userAvatar,
    this.userId,
    this.reviewStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息栏
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 20,
                  backgroundImage: userAvatar != null 
                      ? AssetImage(userAvatar!) 
                      : AssetImage(AppAssets.defaultAvatar),
                ),
                SizedBox(width: 12),
                // 用户名和时间
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          // 审核中标识（这里需要判断当前动态是否属于当前用户且在审核中）
                          if (_shouldShowReviewStatus()) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '审核中',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getTimeAgo(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 心情分数
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMoodColor(moodScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getMoodEmoji(moodScore),
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 4),
                      Text(
                        moodScore.toStringAsFixed(1),
                        style: TextStyle(
                          color: _getMoodColor(moodScore),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 内容
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          // 图片（如果有）
          if (imageUrl != null) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
          // 底部操作栏
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onFavoritePressed,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFavorite ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFavorite ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite ? AppColors.primary : AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          isFavorite ? '已喜欢' : '喜欢',
                          style: TextStyle(
                            fontSize: 12,
                            color: isFavorite ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isFavorite ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                // 举报按钮
                GestureDetector(
                  onTap: () => _showReportDialog(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '举报',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  Color _getMoodColor(double moodScore) {
    if (moodScore >= 8.0) {
      return Colors.green;
    } else if (moodScore >= 6.0) {
      return AppColors.primary;
    } else if (moodScore >= 4.0) {
      return AppColors.warning;
    } else {
      return Colors.red.withOpacity(0.8);
    }
  }

  String _getMoodEmoji(double moodScore) {
    if (moodScore >= 8.0) {
      return '😄';
    } else if (moodScore >= 6.0) {
      return '😊';
    } else if (moodScore >= 4.0) {
      return '😐';
    } else {
      return '😢';
    }
  }

  void _showReportDialog(BuildContext context) {
    final reportService = ReportService();
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetContent: content,
        targetType: 'post',
        targetId: reportService.generateTargetId(content),
      ),
    );
  }

  // 判断是否应该显示审核状态
  bool _shouldShowReviewStatus() {
    return userId != null && 
           reviewStatus == ReviewStatus.pending && 
           UserService.isCurrentUser(userId!);
  }
} 