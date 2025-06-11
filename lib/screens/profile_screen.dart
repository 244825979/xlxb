import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/profile_provider.dart';
import '../utils/avatar_utils.dart';
import '../models/voice_record.dart';
import '../models/mood_data.dart';
import '../services/storage_service.dart';
import '../services/apple_signin_service.dart';
import 'mood_history_screen.dart';
import 'main_screen.dart';
import 'liked_posts_screen.dart';
import 'liked_quotes_screen.dart';
import 'settings_screen.dart';
import 'recharge_screen.dart';
import 'account_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isVip = false;
  bool _isLoadingVip = true;

  @override
  void initState() {
    super.initState();
    _loadVipStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面重新显示时刷新VIP状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVipStatus();
    });
  }

  Future<void> _loadVipStatus() async {
    try {
      final isSignedIn = await AppleSignInService.isAppleSignedIn();
      if (isSignedIn) {
        final userInfo = await AppleSignInService.getCurrentUser();
        if (userInfo != null) {
          final userIdentifier = userInfo['userIdentifier'] as String?;
          if (userIdentifier != null) {
            final prefs = await SharedPreferences.getInstance();
            bool isVip = prefs.getBool('user_vip_status_$userIdentifier') ?? false;
            
            // 如果VIP状态为true，检查是否过期
            if (isVip) {
              final expireTime = prefs.getInt('user_vip_expire_time_$userIdentifier') ?? 0;
              if (expireTime > 0) {
                final expireDateTime = DateTime.fromMillisecondsSinceEpoch(expireTime);
                if (DateTime.now().isAfter(expireDateTime)) {
                  // VIP已过期，重置状态
                  isVip = false;
                  await prefs.setBool('user_vip_status_$userIdentifier', false);
                }
              }
            }
            
            setState(() {
              _isVip = isVip;
              _isLoadingVip = false;
            });
          }
        }
      } else {
        setState(() {
          _isVip = false;
          _isLoadingVip = false;
        });
      }
    } catch (e) {
      setState(() {
        _isVip = false;
        _isLoadingVip = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.playButton),
                ),
              );
            }

            final profile = provider.userProfile;
            if (profile == null) {
              return Center(
                child: Text('用户资料加载失败'),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.profileTitle,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.settings_outlined,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 30),
                    
                    // 用户信息卡片
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [AppColors.cardShadow],
                      ),
                      child: Column(
                        children: [
                          // 头像和基本信息
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(AvatarUtils.userAvatar),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            profile.name,
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _isVip ? Colors.red[600] : null,
                                            ),
                                          ),
                                        ),
                                        if (_isVip) ...[
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFFFD700), // 金色
                                                  Color(0xFFFFA500), // 橙色
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.diamond,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'VIP',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      AppStrings.voiceSignature,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // 统计信息
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _navigateToLikedPosts(context),
                                child: _buildStatItem(
                                  context,
                                  '${profile.likedPosts}',
                                  '喜欢动态',
                                ),
                              ),
                              SizedBox(width: 60), // 添加固定间距
                              GestureDetector(
                                onTap: () => _navigateToLikedQuotes(context),
                                child: _buildStatItem(
                                  context,
                                  '${profile.likedQuotes}',
                                  '喜欢语录',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // 会员升级入口
                    _buildPremiumUpgradeCard(context),
                    
                    SizedBox(height: 20),
                    
                    // 账户管理入口
                    _buildAccountManagementCard(context),
                    
                    SizedBox(height: 20),
                    
                    // 最近7天心情指数
                    _buildMoodTrendCard(context, provider),
                    
                    SizedBox(height: 20),
                    
                    // 喜欢的动态标题和内容
                    GestureDetector(
                      onTap: () => _navigateToLikedPosts(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '喜欢的动态',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // 喜欢的动态列表或空状态提示
                          _buildLikedPosts(context, provider),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.playButton,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyVoiceRecordsHint(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        children: [
          Icon(
            Icons.mic_none_outlined,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            '还没有心声记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '开始记录您的心情和想法\n让AI助手陪伴您的情感之旅',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.playButton.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.playButton.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AppColors.playButton,
                ),
                SizedBox(width: 8),
                Text(
                  '前往首页开始记录',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.playButton,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建最近7天心情指数卡片
  Widget _buildMoodTrendCard(BuildContext context, ProfileProvider provider) {
    return FutureBuilder<List<MoodData>>(
      future: _getRecentMoodData(provider),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.softShadow],
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.playButton),
                strokeWidth: 2,
              ),
            ),
          );
        }

        final moodData = snapshot.data!;
        
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最近7天心情指数',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '平均 ${_calculateAverageMood(moodData).toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // 心情指数条形图
              _buildMoodBars(context, moodData),
              
              SizedBox(height: 12),
              
              // 日期标签
              _buildDateLabels(context, moodData),
              
              SizedBox(height: 16),
              
              // 统计信息和查看详情按钮
              _buildMoodStats(context, moodData),
            ],
          ),
        );
      },
    );
  }

  // 获取最近7天心情数据
  Future<List<MoodData>> _getRecentMoodData(ProfileProvider provider) async {
    try {
      // 从存储中获取所有心情数据
      final storageService = StorageService();
      await storageService.initialize();
      final allMoodData = await storageService.getMoodData();
      final now = DateTime.now();
      final recentMoodData = <MoodData>[];

      // 获取最近7天（包括今天）的数据
      for (int i = 0; i < 7; i++) {
        final targetDate = now.subtract(Duration(days: i));
        
        // 查找这一天的所有心情记录
        final dayMoods = allMoodData.where((mood) {
          return mood.date.year == targetDate.year &&
                 mood.date.month == targetDate.month &&
                 mood.date.day == targetDate.day;
        }).toList();
        
        if (dayMoods.isNotEmpty) {
          // 如果有记录，取分数最高的
          dayMoods.sort((a, b) => b.moodScore.compareTo(a.moodScore));
          recentMoodData.add(dayMoods.first);
        } else {
          // 如果没有记录，创建默认的中性心情
          recentMoodData.add(MoodData(
            date: targetDate,
            moodScore: 5.0,
            moodDescription: '未记录',
          ));
        }
      }

      // 按日期排序，最新的在前面（今天在最左边）
      recentMoodData.sort((a, b) => b.date.compareTo(a.date));
      return recentMoodData;
    } catch (e) {
      print('获取心情数据失败: $e');
      // 返回默认数据
      final now = DateTime.now();
      return List.generate(7, (index) {
        return MoodData(
          date: now.subtract(Duration(days: 6 - index)),
          moodScore: 5.0 + (index * 0.5), // 生成一些变化
          moodDescription: '默认心情',
        );
      });
    }
  }

  // 构建心情指数条形图
  Widget _buildMoodBars(BuildContext context, List<MoodData> moodData) {
    final maxHeight = 60.0;
    
    return Container(
      height: maxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: moodData.map((mood) {
          final normalizedHeight = (mood.moodScore / 10.0) * maxHeight;
          final color = _getMoodColor(mood.moodScore);
          
          return Flexible(
            child: Container(
              width: 24,
              height: normalizedHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 构建日期标签
  Widget _buildDateLabels(BuildContext context, List<MoodData> moodData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moodData.map((mood) {
        final isToday = _isToday(mood.date);
        final dayLabel = isToday ? '今天' : '${mood.date.month}/${mood.date.day}';
        
        return Flexible(
          child: Text(
            dayLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isToday ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  // 计算平均心情
  double _calculateAverageMood(List<MoodData> moodData) {
    if (moodData.isEmpty) return 5.0;
    final sum = moodData.fold(0.0, (sum, mood) => sum + mood.moodScore);
    return sum / moodData.length;
  }

  // 判断是否为今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // 根据心情分数获取颜色
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

  // 根据心情分数获取表情符号
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

  // 构建统计信息和查看详情按钮
  Widget _buildMoodStats(BuildContext context, List<MoodData> moodData) {
    return FutureBuilder<int>(
      future: _getTotalMoodRecords(),
      builder: (context, snapshot) {
        final totalRecords = snapshot.data ?? 0;
        final recordedDays = moodData.where((mood) => mood.moodDescription != '未记录').length;
        
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 统计信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    context,
                    '$totalRecords',
                    '总记录数',
                    Icons.mood,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  _buildStatColumn(
                    context,
                    '$recordedDays',
                    '记录天数',
                    Icons.calendar_today,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  _buildStatColumn(
                    context,
                    '${_calculateAverageMood(moodData).toStringAsFixed(1)}',
                    '平均心情',
                    Icons.trending_up,
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // 查看详情按钮
              GestureDetector(
                onTap: () => _navigateToMoodHistory(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '查看心情指数记录',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建统计列
  Widget _buildStatColumn(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // 获取总心情记录数
  Future<int> _getTotalMoodRecords() async {
    try {
      final storageService = StorageService();
      await storageService.initialize();
      final allMoodData = await storageService.getMoodData();
      return allMoodData.length;
    } catch (e) {
      print('获取总记录数失败: $e');
      return 0;
    }
  }

  // 导航到心情历史页面
  void _navigateToMoodHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodHistoryScreen(),
      ),
    );
  }

  // 导航到广场页面
  void _navigateToPlaza(BuildContext context) {
    // 使用MainScreen的静态方法切换到广场页标签
    MainScreen.switchToPlazaTab(context);
  }

  // 构建动态记录列表或空状态提示
  Widget _buildMyDynamics(BuildContext context, ProfileProvider provider) {
    if (provider.recentRecords.isEmpty) {
      return _buildEmptyDynamicsHint(context);
    }

    List<Widget> dynamicWidgets = [];
    
    // 添加动态卡片
    for (var record in provider.recentRecords.take(3)) {
      dynamicWidgets.add(Container(
        margin: EdgeInsets.only(bottom: 16),
        child: _buildVoiceRecordItem(context, record, false),
      ));
    }
    
    // 添加查看全部动态按钮
    dynamicWidgets.add(_buildViewAllDynamicsButton(context));

    return Column(children: dynamicWidgets);
  }

  // 构建单个动态卡片
  Widget _buildVoiceRecordItem(BuildContext context, VoiceRecord record, bool isDynamicPost) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Row(
        children: [
          // 左侧图标
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDynamicPost ? Icons.dynamic_feed : Icons.record_voice_over,
              color: AppColors.playButton,
              size: 24,
            ),
          ),
          
          SizedBox(width: 12),
          
          // 中间内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和心情标签行
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // 心情标签
                    if (record.moodScore != null && record.moodScore! > 0)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getMoodColor(record.moodScore!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getMoodEmoji(record.moodScore!),
                              style: TextStyle(fontSize: 10),
                            ),
                            SizedBox(width: 2),
                            Text(
                              record.moodScore!.toStringAsFixed(1),
                              style: TextStyle(
                                color: _getMoodColor(record.moodScore!),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 4),
                
                // 日期和描述信息
                Row(
                  children: [
                    Text(
                      record.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (record.description?.isNotEmpty == true) ...[
                      SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          record.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  // 构建查看全部动态按钮
  Widget _buildViewAllDynamicsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPlaza(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              color: AppColors.primary,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              '查看全部动态',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  // 构建空动态提示
  Widget _buildEmptyDynamicsHint(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Row(
        children: [
          // 左侧图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.dynamic_feed_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          
          SizedBox(width: 16),
          
          // 中间文本内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '还没有动态记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 4),
                
                Text(
                  '开始记录您的心情和想法，让每一个瞬间都值得珍藏',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 12),
          
          // 右侧按钮
          GestureDetector(
            onTap: () => _navigateToPlaza(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '开始记录',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建喜欢的动态列表或空状态提示
  Widget _buildLikedPosts(BuildContext context, ProfileProvider provider) {
    final likedPosts = provider.userProfile?.favoriteRecords ?? [];
    
    if (likedPosts.isEmpty) {
      return _buildEmptyStateCard(
        context,
        icon: Icons.favorite_border,
        title: '还没有喜欢的动态',
        description: '浏览广场，为喜欢的动态点赞',
        buttonText: '去看看',
        onPressed: () => _navigateToPlaza(context),
      );
    }

    return Column(
      children: [
        ...likedPosts.take(3).map((post) {
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            child: _buildVoiceRecordItem(context, post, true),
          );
        }).toList(),
        
        // 查看全部按钮
        GestureDetector(
          onTap: () => _navigateToLikedPosts(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.softShadow],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  '查看全部喜欢的动态',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 导航到喜欢的动态页面
  void _navigateToLikedPosts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LikedPostsScreen(),
      ),
    );
  }

  // 构建空状态卡片
  Widget _buildEmptyStateCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 4),
                
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 12),
          
          GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 导航到喜欢的语录页面
  void _navigateToLikedQuotes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LikedQuotesScreen(),
      ),
    );
  }

  // 构建会员升级入口卡片
  Widget _buildPremiumUpgradeCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RechargeScreen(),
          ),
        );
        // 从充值页面返回后刷新VIP状态
        _loadVipStatus();
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            // 左侧图标
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.playButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.wallet,
                color: AppColors.playButton,
                size: 24,
              ),
            ),
            
            SizedBox(width: 16),
            
            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '充值中心',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '金币 • 会员 • 更多功能',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 右侧箭头
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 构建账户管理入口卡片
  Widget _buildAccountManagementCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountManagementScreen(),
          ),
        );
        // 从账户管理页面返回后刷新VIP状态
        _loadVipStatus();
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            // 左侧图标
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_circle,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            
            SizedBox(width: 16),
            
            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '账户管理',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Apple ID • 支付方式 • 安全设置',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 右侧箭头
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 