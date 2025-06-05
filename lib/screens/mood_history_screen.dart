import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/mood_data.dart';
import '../services/storage_service.dart';

class MoodHistoryScreen extends StatefulWidget {
  @override
  _MoodHistoryScreenState createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  final StorageService _storageService = StorageService();
  List<MoodData> _allMoodData = [];
  bool _isLoading = true;
  String _selectedFilter = '全部';

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    try {
      await _storageService.initialize();
      final moodData = await _storageService.getMoodData();
      setState(() {
        _allMoodData = moodData;
        _isLoading = false;
      });
    } catch (e) {
      print('加载心情历史失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<MoodData> get _filteredMoodData {
    // 获取今天的日期（不包含时分秒）
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // 首先过滤掉未来的数据
    final validData = _allMoodData.where((mood) => mood.date.isBefore(today)).toList();
    
    // 然后根据选择的过滤条件进行筛选
    switch (_selectedFilter) {
      case '极佳':
        return validData.where((mood) => mood.moodScore >= 8.0).toList();
      case '良好':
        return validData.where((mood) => mood.moodScore >= 6.0 && mood.moodScore < 8.0).toList();
      case '一般':
        return validData.where((mood) => mood.moodScore >= 4.0 && mood.moodScore < 6.0).toList();
      case '较差':
        return validData.where((mood) => mood.moodScore < 4.0).toList();
      default:
        return validData;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏为黑色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '心情指数记录',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Column(
              children: [
                // 统计信息头部
                _buildStatsHeader(),
                
                // 筛选器
                _buildFilterBar(),
                
                // 心情记录列表
                Expanded(
                  child: _buildMoodList(),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader() {
    // 获取今天的日期（不包含时分秒）
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // 过滤出有效的心情数据
    final validData = _allMoodData.where((mood) => mood.date.isBefore(today)).toList();
    
    final totalRecords = validData.length;
    final averageScore = totalRecords > 0
        ? validData.fold(0.0, (sum, mood) => sum + mood.moodScore) / totalRecords
        : 0.0;
    final highestScore = totalRecords > 0
        ? validData.map((mood) => mood.moodScore).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(20),
      color: AppColors.cardBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('$totalRecords', '总记录', Icons.list),
          _buildStatItem('${averageScore.toStringAsFixed(1)}', '平均分', Icons.trending_up),
          _buildStatItem('${highestScore.toStringAsFixed(1)}', '最高分', Icons.star),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['全部', '极佳', '良好', '一般', '较差'];
    
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.cardBackground,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMoodList() {
    final filteredData = _filteredMoodData;
    
    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mood_bad,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              _selectedFilter == '全部' ? '暂无心情记录' : '该分类下暂无记录',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // 按日期倒序排列
    filteredData.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final mood = filteredData[index];
        return _buildMoodCard(mood);
      },
    );
  }

  Widget _buildMoodCard(MoodData mood) {
    final moodColor = _getMoodColor(mood.moodScore);
    final moodEmoji = _getMoodEmoji(mood.moodScore);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.softShadow],
        border: Border.all(
          color: moodColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 心情图标和分数
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: moodColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  moodEmoji,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  mood.moodScore.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: moodColor,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 16),
          
          // 心情信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood.moodDescription,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDate(mood.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (mood.note?.isNotEmpty == true) ...[
                  SizedBox(height: 8),
                  Text(
                    mood.note!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // 心情分数标签
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: moodColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getMoodLabel(mood.moodScore),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

  String _getMoodLabel(double moodScore) {
    if (moodScore >= 8.0) {
      return '极佳';
    } else if (moodScore >= 6.0) {
      return '良好';
    } else if (moodScore >= 4.0) {
      return '一般';
    } else {
      return '较差';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;
    
    if (difference == 0) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference > 1 && difference < 7) {
      return '$difference天前 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
} 