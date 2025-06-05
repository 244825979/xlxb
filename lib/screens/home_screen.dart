import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/home_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/notifications_screen.dart';
import '../widgets/voice_player_card.dart';
import '../widgets/music_player_card.dart';
import '../widgets/daily_quote_card.dart';
import '../widgets/mood_indicator.dart';
import '../screens/publish_mood_screen.dart';
import '../constants/app_assets.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.playButton),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: provider.refresh,
              color: AppColors.playButton,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题栏
                    _buildHeader(context),
                    
                    SizedBox(height: 24),
                    
                    // 今日心情指示器
                    if (provider.todayMood != null)
                      MoodIndicator(
                        moodData: provider.todayMood!,
                        onTap: () => _showMoodDialog(context, provider),
                      ),
                    
                    SizedBox(height: 24),
                    
                    // 宁静音乐播放器
                    if (provider.musicTracks.isNotEmpty)
                      MusicPlayerCard(
                        tracks: provider.musicTracks,
                        currentTrackIndex: provider.currentTrackIndex,
                        isPlaying: provider.isPlaying,
                        progress: provider.playProgress,
                        currentPosition: provider.currentPosition,
                        totalDuration: provider.totalDuration,
                        onPlayPause: provider.toggleMusicPlayPause,
                        onNext: provider.playNextTrack,
                        onPrevious: provider.playPreviousTrack,
                        onSeek: provider.seekMusicTo,
                      ),
                    
                    SizedBox(height: 24),
                    
                    // 每日语录卡片
                    DailyQuoteCard(
                      quote: provider.dailyQuote,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // 发布心情语录卡片
                    _buildPublishMoodCard(context),
                    
                    SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.homeTitle,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
                  GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            ),
            child: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.unreadCount == 0) return SizedBox.shrink();
                    return Positioned(
                      right: 8,
                      top: 6,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Center(
                          child: Text(
                            provider.unreadCount > 99 ? '99+' : provider.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPublishMoodCard(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.month}月${now.day}日';
    final provider = Provider.of<HomeProvider>(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublishMoodScreen(
              initialMood: provider.todayMood,
            ),
          ),
        );
      },
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
            // 标题行
            Row(
              children: [
                // 左侧图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.playButton,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                // 中间文本
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '发布我的今日心情语录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 右侧箭头或状态
                if (provider.publishedMoodQuote != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '已发布',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
              ],
            ),
            
            // 已发布的内容
            if (provider.publishedMoodQuote != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 心情图标
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: provider.todayMood != null 
                          ? Image.asset(
                              provider.todayMood!.moodImage,
                              width: 28,
                              height: 28,
                            )
                          : Icon(
                              Icons.mood,
                              color: AppColors.playButton,
                              size: 28,
                            ),
                    ),
                    SizedBox(width: 12),
                    // 内容和时间
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.publishedMoodQuote!,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${_formatTime(provider.publishedMoodTime!)} ${provider.todayMood?.moodLabel ?? ""}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已发布',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PublishMoodScreen(
                            initialMood: provider.todayMood,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            color: AppColors.playButton,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '编辑',
                            style: TextStyle(
                              color: AppColors.playButton,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildFeatureTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.playButton,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '早上好，愿你有美好的一天';
    } else if (hour < 18) {
      return '下午好，享受这宁静的时光';
    } else {
      return '晚上好，让心灵得到放松';
    }
  }

  void _showMoodDialog(BuildContext context, HomeProvider provider) {
    final List<Map<String, dynamic>> moodLevels = [
      {'score': 10.0, 'image': AppAssets.moodImages[0], 'label': '超开心'},
      {'score': 8.0, 'image': AppAssets.moodImages[1], 'label': '舒畅'},
      {'score': 5.0, 'image': AppAssets.moodImages[2], 'label': '一般'},
      {'score': 3.0, 'image': AppAssets.moodImages[3], 'label': '不开心'},
      {'score': 1.0, 'image': AppAssets.moodImages[4], 'label': '难过'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('今日心情'),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('选择你今天的心情状态：'),
              SizedBox(height: 24),
              // 上排3个表情
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: moodLevels.take(3).map((mood) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMoodButton(
                      mood['image'],
                      mood['score'],
                      mood['label'],
                      provider,
                    ),
                    SizedBox(height: 8),
                    Text(
                      mood['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )).toList(),
              ),
              SizedBox(height: 16),
              // 下排2个表情
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...moodLevels.skip(3).map((mood) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMoodButton(
                          mood['image'],
                          mood['score'],
                          mood['label'],
                          provider,
                        ),
                        SizedBox(height: 8),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String image, double score, String label, HomeProvider provider) {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () async {
            await provider.updateTodayMood(score, label);
            Navigator.of(context).pop();
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 36,
                height: 36,
              ),
            ),
          ),
        );
      },
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