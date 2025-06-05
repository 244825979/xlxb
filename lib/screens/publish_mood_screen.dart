import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_assets.dart';
import '../providers/home_provider.dart';
import '../models/mood_data.dart';

class PublishMoodScreen extends StatefulWidget {
  final dynamic initialMood;

  const PublishMoodScreen({
    super.key,
    this.initialMood,
  });

  @override
  State<PublishMoodScreen> createState() => _PublishMoodScreenState();
}

class _PublishMoodScreenState extends State<PublishMoodScreen> {
  final TextEditingController _contentController = TextEditingController();
  late double _moodScore;
  
  final List<Map<String, dynamic>> _moodOptions = [
    {
      'score': 10.0, 
      'image': AppAssets.moodImages[0], 
      'label': '超开心',
      'defaultText': '今天的心情特别好，阳光明媚，一切都很美好！感谢生活带给我的每一份快乐和惊喜。'
    },
    {
      'score': 8.0, 
      'image': AppAssets.moodImages[1], 
      'label': '舒畅',
      'defaultText': '心情舒畅，内心平静而满足。今天的自己状态很好，希望这份美好能够延续下去。'
    },
    {
      'score': 5.0, 
      'image': AppAssets.moodImages[2], 
      'label': '一般',
      'defaultText': '今天的心情比较平静，没有特别的起伏。生活就是这样，平平淡淡也是一种幸福。'
    },
    {
      'score': 3.0, 
      'image': AppAssets.moodImages[3], 
      'label': '不开心',
      'defaultText': '今天心情有些低落，可能是遇到了一些小困难。相信明天会更好，给自己一些时间调整。'
    },
    {
      'score': 1.0, 
      'image': AppAssets.moodImages[4], 
      'label': '难过',
      'defaultText': '今天很难过，心情很沉重。但我知道这只是暂时的，困难总会过去，阳光总在风雨后。'
    },
  ];

  @override
  void initState() {
    super.initState();
    // 如果有初始心情数据，使用它的分数，否则默认为"一般"(5.0)
    _moodScore = widget.initialMood?.moodScore ?? 5.0;
    
    // 根据心情分数获取对应的默认文本
    final defaultMood = _moodOptions.firstWhere(
      (mood) => mood['score'] == _moodScore,
      orElse: () => _moodOptions[2], // 默认"一般"
    );
    
    // 设置文本框内容为当前心情对应的默认文本
    _contentController.text = defaultMood['defaultText'];
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
            '发布心情语录',
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
          actions: [
            TextButton(
              onPressed: _publishMood,
              child: Text(
                '发布',
                style: TextStyle(
                  color: AppColors.playButton,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 心情指数选择
              _buildMoodSelector(),
              
              SizedBox(height: 30),
              
              // 心情内容输入
              _buildContentInput(),
              
              SizedBox(height: 30),
              
              // 预览区域
              _buildPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mood,
                color: AppColors.playButton,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '今日心情指数',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // 心情选项
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _moodOptions.map((mood) {
              final isSelected = _moodScore == mood['score'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _moodScore = mood['score'];
                    // 更新文本框内容为当前选中心情的默认文本
                    _contentController.text = mood['defaultText'];
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        mood['image'],
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 6),
                      Text(
                        mood['label'],
                        style: TextStyle(
                          color: isSelected 
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected 
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                color: AppColors.playButton,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '分享你的心情',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          TextField(
            controller: _contentController,
            maxLines: 5,
            maxLength: 200,
            decoration: InputDecoration(
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
              fillColor: AppColors.background,
            ),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_contentController.text.isEmpty) return SizedBox.shrink();
    
    final selectedMood = _moodOptions.firstWhere(
      (mood) => mood['score'] == _moodScore,
      orElse: () => _moodOptions[2], // 默认"一般"
    );
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: AppColors.playButton,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '预览',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // 预览内容
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  selectedMood['image'],
                  width: 36,
                  height: 36,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contentController.text,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${DateTime.now().month}月${DateTime.now().day}日 ${selectedMood['label']}',
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
        ],
      ),
    );
  }

  void _publishMood() async {
    if (_contentController.text.isEmpty) {
      // 显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入心情语录内容'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedMood = _moodOptions.firstWhere(
      (mood) => mood['score'] == _moodScore,
      orElse: () => _moodOptions[2], // 默认"一般"
    );

    // 发布心情语录
    await context.read<HomeProvider>().publishMoodQuote(
      _contentController.text,
      selectedMood['score'],
    );

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('心情语录发布成功！'),
        backgroundColor: Colors.green,
      ),
    );

    // 返回上一页
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
} 