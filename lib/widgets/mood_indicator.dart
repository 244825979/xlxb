import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/mood_data.dart';

class MoodIndicator extends StatelessWidget {
  final MoodData moodData;
  final VoidCallback? onTap;

  const MoodIndicator({
    Key? key,
    required this.moodData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.softShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和图标
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getMoodColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mood,
                        color: _getMoodColor(),
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.todayMood,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (onTap != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMoodColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: _getMoodColor(),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '编辑',
                          style: TextStyle(
                            color: _getMoodColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // 心情状态和分数
            Row(
              children: [
                // 心情图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getMoodColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Image.asset(
                      moodData.moodImage,
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // 心情信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moodData.moodLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 心情分数
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMoodColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moodData.moodScore.toStringAsFixed(1),
                    style: TextStyle(
                      color: _getMoodColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor() {
    final score = moodData.moodScore;
    if (score >= 8.0) return AppColors.success;
    if (score >= 6.0) return AppColors.playButton;
    if (score >= 4.0) return AppColors.primary;
    if (score >= 2.0) return AppColors.warning;
    return AppColors.error;
  }
} 