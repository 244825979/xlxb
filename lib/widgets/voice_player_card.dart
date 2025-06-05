import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/voice_record.dart';

class VoicePlayerCard extends StatelessWidget {
  final VoiceRecord voiceRecord;
  final bool isPlaying;
  final double progress;
  final VoidCallback onPlayPause;
  final Function(double) onSeek;

  const VoicePlayerCard({
    Key? key,
    required this.voiceRecord,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPause,
    required this.onSeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和描述
          Text(
            voiceRecord.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          if (voiceRecord.description != null)
            Text(
              voiceRecord.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          
          SizedBox(height: 24),
          
          // 播放控制区域
          Row(
            children: [
              // 播放/暂停按钮
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.playButton,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.playButton.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // 进度条和时间
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 进度条
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.playButton,
                        inactiveTrackColor: AppColors.playButton.withOpacity(0.3),
                        thumbColor: AppColors.playButton,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                        trackHeight: 4,
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: onSeek,
                      ),
                    ),
                    
                    // 时间显示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(Duration(
                            milliseconds: (voiceRecord.duration.inMilliseconds * progress).round(),
                          )),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          voiceRecord.formattedDuration,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // 心情分数和日期
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (voiceRecord.moodScore != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: AppColors.favoriteRed,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${voiceRecord.moodScore!.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              
              Text(
                voiceRecord.formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
} 