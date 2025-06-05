import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? _selectedFeedback;
  final TextEditingController _detailController = TextEditingController();
  bool _isSubmitting = false;

  final List<FeedbackOption> _feedbackOptions = [
    FeedbackOption(
      icon: Icons.psychology,
      title: '回答不够贴心',
      description: '助手的回答不够温暖或理解我的感受',
    ),
    FeedbackOption(
      icon: Icons.error_outline,
      title: '回答不够准确',
      description: '助手的回答偏离了我的问题重点',
    ),
    FeedbackOption(
      icon: Icons.speed,
      title: '响应太慢',
      description: '等待回复的时间过长',
    ),
    FeedbackOption(
      icon: Icons.repeat,
      title: '回答重复',
      description: '助手的回答存在重复或冗余内容',
    ),
    FeedbackOption(
      icon: Icons.sentiment_very_dissatisfied,
      title: '其他问题',
      description: '其他需要改进的地方',
    ),
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_selectedFeedback == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请选择反馈类型')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // TODO: 实现反馈提交逻辑

    // 模拟提交延迟
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      // 显示感谢弹窗
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.playButton.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.playButton,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '感谢您的反馈！',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '您的每一条建议都是我们进步的动力。\n我们会认真考虑您的反馈，\n努力为您提供更好的服务。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 关闭弹窗
                        Navigator.of(context).pop(); // 返回聊天页面
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.playButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '我知道了',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        barrierDismissible: false,
      );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '意见反馈',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '请选择反馈类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              ..._feedbackOptions.map((option) => _buildFeedbackOption(option)),
              SizedBox(height: 24),
              Text(
                '详细说明（选填）',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [AppColors.softShadow],
                ),
                child: TextField(
                  controller: _detailController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: '请描述您遇到的具体问题...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.playButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '提交反馈',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackOption(FeedbackOption option) {
    final isSelected = _selectedFeedback == option.title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeedback = option.title;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.playButton.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.playButton : Colors.transparent,
            width: 2,
          ),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.playButton : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.playButton : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackOption {
  final IconData icon;
  final String title;
  final String description;

  FeedbackOption({
    required this.icon,
    required this.title,
    required this.description,
  });
} 