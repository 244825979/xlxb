import 'package:flutter/material.dart';
import '../models/music_track.dart';
import '../constants/app_colors.dart';

class MusicPlayerCard extends StatelessWidget {
  final List<MusicTrack> tracks;
  final int currentTrackIndex;
  final bool isPlaying;
  final double progress;
  final Duration currentPosition;
  final Duration totalDuration;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final ValueChanged<double>? onSeek;

  const MusicPlayerCard({
    Key? key,
    required this.tracks,
    required this.currentTrackIndex,
    required this.isPlaying,
    required this.progress,
    required this.currentPosition,
    required this.totalDuration,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onSeek,
  }) : super(key: key);

  MusicTrack get currentTrack => tracks.isNotEmpty && currentTrackIndex < tracks.length 
      ? tracks[currentTrackIndex] 
      : tracks.first;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return SizedBox.shrink();

    // 添加调试信息
    print('MusicPlayerCard - 播放状态: $isPlaying, 进度: $progress, 当前时间: ${_formatDuration(currentPosition)}, 总时间: ${_formatDuration(totalDuration)}');

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和描述
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: AppColors.playButton,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTrack.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      currentTrack.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // 播放控制区域
          Row(
            children: [
              // 上一曲按钮
              if (tracks.length > 1)
                IconButton(
                  onPressed: onPrevious,
                  icon: Icon(
                    Icons.skip_previous,
                    color: currentTrackIndex > 0 
                        ? AppColors.playButton 
                        : AppColors.textLight,
                    size: 28,
                  ),
                ),

              // 播放/暂停按钮
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.playButton,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.playButton.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              // 下一曲按钮
              if (tracks.length > 1)
                IconButton(
                  onPressed: onNext,
                  icon: Icon(
                    Icons.skip_next,
                    color: currentTrackIndex < tracks.length - 1 
                        ? AppColors.playButton 
                        : AppColors.textLight,
                    size: 28,
                  ),
                ),

              Spacer(),

              // 时间显示
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    totalDuration.inMilliseconds > 0 
                        ? _formatDuration(totalDuration)
                        : (currentTrack.estimatedDuration != null 
                            ? '~${_formatDuration(currentTrack.estimatedDuration!)}'
                            : '--:--'),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16),

          // 播放进度条
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.playButton,
                  inactiveTrackColor: AppColors.textLight.withOpacity(0.3),
                  thumbColor: AppColors.playButton,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: totalDuration.inMilliseconds > 0 
                      ? progress.clamp(0.0, 1.0)
                      : 0.0,
                  onChanged: totalDuration.inMilliseconds > 0 ? onSeek : null,
                ),
              ),
              // 如果没有时长信息，显示提示
              if (totalDuration.inMilliseconds == 0 && isPlaying)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '正在加载音频信息...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              // 音乐选择指示器移到底部中间
              if (tracks.length > 1)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: tracks.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Container(
                        width: 6,
                        height: 6,
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentTrackIndex 
                              ? AppColors.playButton 
                              : AppColors.textLight.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
} 