import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report.dart';
import 'user_service.dart';

class ReportService {
  static const String _reportsKey = 'reports';
  
  // 提交举报
  Future<bool> submitReport(Report report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reports = await getReports();
      
      reports.add(report);
      
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, jsonEncode(reportsJson));
      
      return true;
    } catch (e) {
      print('提交举报失败: $e');
      return false;
    }
  }
  
  // 获取所有举报
  Future<List<Report>> getReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsString = prefs.getString(_reportsKey);
      
      if (reportsString == null) return [];
      
      final reportsJson = jsonDecode(reportsString) as List;
      return reportsJson.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      print('获取举报列表失败: $e');
      return [];
    }
  }
  
  // 获取用户的举报历史
  Future<List<Report>> getUserReports(String userId) async {
    try {
      final reports = await getReports();
      
      // 只有在完全没有数据时才初始化示例数据
      if (reports.isEmpty) {
        await _initializeSampleData();
        final newReports = await getReports();
        return newReports.where((report) => report.reporterId == userId).toList();
      }
      
      // 返回该用户的所有举报记录，按时间倒序排列
      final userReports = reports.where((report) => report.reporterId == userId).toList();
      userReports.sort((a, b) => b.reportTime.compareTo(a.reportTime));
      return userReports;
    } catch (e) {
      print('获取用户举报历史失败: $e');
      return [];
    }
  }
  
  // 检查内容是否已被用户举报
  Future<bool> hasUserReported(String userId, String targetId, String targetType) async {
    try {
      final reports = await getReports();
      return reports.any((report) => 
        report.reporterId == userId && 
        report.targetId == targetId && 
        report.targetType == targetType
      );
    } catch (e) {
      print('检查举报状态失败: $e');
      return false;
    }
  }
  
  // 更新举报状态（管理员功能）
  Future<bool> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      final reports = await getReports();
      final index = reports.indexWhere((r) => r.id == reportId);
      
      if (index == -1) return false;
      
      reports[index] = reports[index].copyWith(status: status);
      
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, jsonEncode(reportsJson));
      
      return true;
    } catch (e) {
      print('更新举报状态失败: $e');
      return false;
    }
  }
  
  // 生成举报ID
  String generateReportId() {
    return 'report_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // 生成目标内容ID（基于内容hash）
  String generateTargetId(String content) {
    return 'quote_${content.hashCode.abs()}';
  }
  
  // 初始化示例数据
  Future<void> _initializeSampleData() async {
    try {
      final currentUserId = UserService.getCurrentUserId();
      final sampleReports = [
        Report(
          id: generateReportId(),
          targetId: 'quote_123',
          targetType: 'quote',
          targetContent: '生活不是等待暴风雨过去，而是学会在雨中起舞。',
          type: ReportType.inappropriate,
          reason: '内容与应用主题不符',
          reporterId: currentUserId,
          reportTime: DateTime.now().subtract(Duration(days: 2)),
          status: ReportStatus.resolved,
        ),
        Report(
          id: generateReportId(),
          targetId: 'post_456',
          targetType: 'post',
          targetContent: '今天心情很好，分享一下我的快乐时光...',
          type: ReportType.spam,
          reason: '重复发布相似内容',
          reporterId: currentUserId,
          reportTime: DateTime.now().subtract(Duration(days: 1)),
          status: ReportStatus.reviewing,
        ),
        Report(
          id: generateReportId(),
          targetId: 'quote_789',
          targetType: 'quote',
          targetContent: '每天都是新的开始，要保持积极的心态。',
          type: ReportType.fake,
          reason: '',
          reporterId: currentUserId,
          reportTime: DateTime.now().subtract(Duration(hours: 6)),
          status: ReportStatus.pending,
        ),
      ];

      for (final report in sampleReports) {
        await submitReport(report);
      }
    } catch (e) {
      print('初始化示例数据失败: $e');
    }
  }
} 