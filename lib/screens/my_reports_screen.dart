import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';

class MyReportsScreen extends StatefulWidget {
  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final ReportService _reportService = ReportService();
  List<Report> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      // 使用用户服务获取当前用户ID
      final currentUserId = UserService.getCurrentUserId();
      final reports = await _reportService.getUserReports(currentUserId);
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载举报记录失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏为黑色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            '我的举报',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading ? _buildLoadingWidget() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_reports.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '暂无举报记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '您还没有提交过任何举报',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(report.status).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(report.targetType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(report.targetType),
                    color: _getTypeColor(report.targetType),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeTitle(report.targetType),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        report.typeDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.statusDescription,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 举报内容
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '举报内容',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    report.targetContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (report.reason.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '举报原因',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    report.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],

                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '举报时间：${_formatDateTime(report.reportTime)}',
                      style: TextStyle(
                        fontSize: 13,
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
    );
  }

  String _getTypeTitle(String targetType) {
    switch (targetType) {
      case 'quote':
        return '官方语录';
      case 'post':
        return '动态举报';
      case 'comment':
        return '评论举报';
      case 'user':
        return '用户举报';
      default:
        return '其他举报';
    }
  }

  IconData _getTypeIcon(String targetType) {
    switch (targetType) {
      case 'quote':
        return Icons.format_quote;
      case 'post':
        return Icons.article_outlined;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'user':
        return Icons.person_outline;
      default:
        return Icons.flag_outlined;
    }
  }

  Color _getTypeColor(String targetType) {
    switch (targetType) {
      case 'quote':
        return AppColors.primary;
      case 'post':
        return Colors.blue;
      case 'comment':
        return Colors.green;
      case 'user':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.reviewing:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 