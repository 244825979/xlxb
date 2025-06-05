import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../screens/my_reports_screen.dart';

class ReportDialog extends StatefulWidget {
  final String targetContent;
  final String targetType;
  final String targetId;

  const ReportDialog({
    Key? key,
    required this.targetContent,
    required this.targetType,
    required this.targetId,
  }) : super(key: key);

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final ReportService _reportService = ReportService();
  ReportType _selectedType = ReportType.inappropriate;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'type': ReportType.inappropriate,
      'title': '不当内容',
      'description': '包含违法、违规或不适宜的内容',
      'icon': Icons.warning_amber_outlined,
    },
    {
      'type': ReportType.spam,
      'title': '垃圾信息',
      'description': '广告、推销或重复发布的内容',
      'icon': Icons.block_outlined,
    },
    {
      'type': ReportType.fake,
      'title': '虚假信息',
      'description': '包含虚假、误导性的信息',
      'icon': Icons.fact_check_outlined,
    },
    {
      'type': ReportType.harassment,
      'title': '骚扰信息',
      'description': '恶意骚扰、侮辱或威胁他人',
      'icon': Icons.person_off_outlined,
    },
    {
      'type': ReportType.copyright,
      'title': '版权问题',
      'description': '涉嫌侵犯版权或知识产权',
      'icon': Icons.copyright_outlined,
    },
    {
      'type': ReportType.other,
      'title': '其他',
      'description': '其他不符合社区规范的内容',
      'icon': Icons.more_horiz_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '举报内容',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 内容区域
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 被举报内容预览
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '举报内容：',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.targetContent,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // 举报类型选择
                    Text(
                      '请选择举报原因：',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),

                    ..._reportTypes.map((typeData) {
                      final bool isSelected = _selectedType == typeData['type'];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: isSelected 
                              ? AppColors.primary.withOpacity(0.1) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedType = typeData['type'];
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : AppColors.textSecondary.withOpacity(0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    typeData['icon'],
                                    color: isSelected 
                                        ? AppColors.primary 
                                        : AppColors.textSecondary,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          typeData['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected 
                                                ? AppColors.primary 
                                                : AppColors.textPrimary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          typeData['description'],
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<ReportType>(
                                    value: typeData['type'],
                                    groupValue: _selectedType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedType = value!;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 24),

                    // 详细描述
                    Text(
                      '详细描述（可选）：',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _reasonController,
                      maxLines: 4,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: '请详细描述您举报此内容的原因...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground.withOpacity(0.3),
                      ),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 底部按钮
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              '提交举报',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // 使用用户服务获取当前用户ID
      final currentUserId = UserService.getCurrentUserId();
      
      // 检查是否已经举报过
      final hasReported = await _reportService.hasUserReported(
        currentUserId,
        widget.targetId,
        widget.targetType,
      );

      if (hasReported) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('您已经举报过此内容'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      final report = Report(
        id: _reportService.generateReportId(),
        targetId: widget.targetId,
        targetType: widget.targetType,
        targetContent: widget.targetContent,
        type: _selectedType,
        reason: _reasonController.text.trim(),
        reporterId: currentUserId,
        reportTime: DateTime.now(),
      );

      final success = await _reportService.submitReport(report);

      if (success) {
        Navigator.of(context).pop(); // 先关闭举报对话框
        _showSuccessDialog(context); // 显示成功对话框
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('举报提交失败，请稍后重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('举报提交失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // 显示成功对话框
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 32,
                  ),
                ),
                
                SizedBox(height: 16),
                
                // 标题
                Text(
                  '举报提交成功',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // 描述
                Text(
                  '我们会在24小时内处理您的举报，感谢您的反馈！',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 24),
                
                // 按钮区域
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Text(
                          '确定',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭成功对话框
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyReportsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '查看记录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
} 