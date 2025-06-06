import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plaza_post.dart';
import '../models/comment.dart';
import '../constants/app_colors.dart';
import '../providers/plaza_provider.dart';
import '../services/storage_service.dart';
import '../widgets/report_dialog.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../services/block_service.dart';
import 'image_view_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final PlazaPost post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isCommentFieldReady = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkCommentFieldReady();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allComments = await _storageService.getComments(widget.post.id);
      print('Total comments loaded: ${allComments.length}'); // 调试信息
      
      // 过滤已屏蔽用户的评论，但不过滤当前用户的评论
      final filteredComments = <Comment>[];
      final blockedUsers = await BlockService.getBlockedUsers();
      final currentUserId = UserService.getCurrentUserId();
      
      for (final comment in allComments) {
        final commentUserId = comment.userId ?? 'unknown';
        print('Comment by user: $commentUserId, blocked: ${blockedUsers.contains(commentUserId)}, is current: ${commentUserId == currentUserId}'); // 调试信息
        
        // 如果是当前用户的评论，或者不是被屏蔽用户的评论，则包含
        if (commentUserId == currentUserId || !blockedUsers.contains(commentUserId)) {
          filteredComments.add(comment);
        }
      }
      
      _comments = filteredComments;
      print('Comments after filtering: ${_comments.length}'); // 调试信息
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('加载评论失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final provider = Provider.of<PlazaProvider>(context, listen: false);
    final success = await provider.addComment(widget.post.id, _commentController.text.trim());
    
    if (success) {
      _commentController.clear();
      // 重新加载评论列表
      await _loadComments();
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('评论发布成功'),
          backgroundColor: AppColors.playButton,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // 显示失败提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('评论发布失败，请重试'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 检查是否需要显示评论合规提醒
  Future<bool> _shouldShowCommentGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('comment_guide_shown') ?? false;
    print('comment_guide_shown: $hasShown'); // 调试信息
    return !hasShown;
  }

  // 标记已显示评论合规提醒
  Future<void> _markCommentGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('comment_guide_shown', true);
    print('Marked comment guide as shown'); // 调试信息
  }

  // 处理评论输入框点击
  Future<void> _handleCommentTap() async {
    print('handleCommentTap called'); // 调试信息
    
    if (!_isCommentFieldReady) {
      // 如果评论框未准备好，显示提醒
      _showCommentGuideDialog();
    }
    // 如果已经准备好，让TextField正常处理点击事件
  }

  // 显示评论合规提醒弹窗
  void _showCommentGuideDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 不能通过点击外部关闭
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppColors.playButton,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              '评论须知',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '感谢您参与互动！为营造和谐的交流环境，请遵守以下规范：',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '请勿发布：',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• 恶意攻击、人身侮辱\n'
                    '• 广告推广、垃圾信息\n'
                    '• 政治敏感、违法内容\n'
                    '• 不实信息、恶意传播',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              '让我们一起传递正能量，构建温暖的心声社区！',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.playButton,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '取消',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 标记已显示提醒
              await _markCommentGuideShown();
              Navigator.of(context).pop();
              // 更新状态，启用评论框
              setState(() {
                _isCommentFieldReady = true;
              });
              // 聚焦到评论输入框
              Future.delayed(Duration(milliseconds: 100), () {
                _commentFocusNode.requestFocus();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.playButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              '我知道了',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 举报功能
  void _reportPost() {
    final reportService = ReportService();
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetContent: widget.post.content,
        targetType: 'post',
        targetId: reportService.generateTargetId(widget.post.content),
      ),
    );
  }

  // 屏蔽帖子
  void _blockPost() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.block,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '屏蔽内容',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '确定要屏蔽这条内容吗？',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '屏蔽后，您将不会再看到这条内容，并会返回上一页。',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '取消',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 执行屏蔽操作
                final provider = Provider.of<PlazaProvider>(context, listen: false);
                await provider.blockPost(widget.post.id);
                // 显示成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已屏蔽该内容'),
                    backgroundColor: AppColors.playButton,
                    duration: Duration(seconds: 2),
                  ),
                );
                // 返回上一页
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                '确定屏蔽',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 举报评论功能
  void _reportComment(Comment comment) {
    final reportService = ReportService();
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetContent: comment.content,
        targetType: 'comment',
        targetId: reportService.generateTargetId(comment.content),
      ),
    );
  }

  // 检查评论框是否可用
  Future<void> _checkCommentFieldReady() async {
    final shouldShow = await _shouldShowCommentGuide();
    setState(() {
      _isCommentFieldReady = !shouldShow;
    });
  }

  // 屏蔽用户功能
  void _blockUser(String userId, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.block,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '屏蔽用户',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '确定要屏蔽用户 "$userName" 吗？',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '屏蔽后，您将不会再看到该用户的任何内容和评论。',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '取消',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 执行屏蔽操作
                await BlockService.blockUser(userId);
                // 重新加载评论列表
                await _loadComments();
                // 显示成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已屏蔽用户 "$userName"'),
                    backgroundColor: AppColors.playButton,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                '确定屏蔽',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏为黑色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '帖子详情',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // 屏蔽按钮 - 只对非当前用户的内容显示
          if (!UserService.isCurrentUser(widget.post.userId))
            TextButton(
              onPressed: _blockPost,
              child: Text(
                '屏蔽',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // 举报按钮 - 只对非当前用户的内容显示
          if (!UserService.isCurrentUser(widget.post.userId))
            TextButton(
              onPressed: _reportPost,
              child: Text(
                '举报',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 帖子内容
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户信息
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(widget.post.userAvatar),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.post.userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  // 审核中标识
                                  if (widget.post.isUnderReview && UserService.isCurrentUser(widget.post.userId)) ...[
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        '审核中',
                                        style: TextStyle(
                                          color: Colors.orange[700],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                widget.post.formattedCreatedAt,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 帖子内容
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.post.content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // 图片内容
                  if (widget.post.hasImage) ...[
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewScreen(
                              imageUrl: widget.post.imageUrl!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: Image.asset(
                          widget.post.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],

                  // 评论列表
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '评论 (${_comments.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (_isLoading)
                          Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.playButton),
                            ),
                          )
                        else if (_comments.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              '暂无评论，快来抢沙发吧~',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._comments.map((comment) => CommentItem(
                            comment: comment,
                            onReport: () => _reportComment(comment),
                            onBlockUser: () => _blockUser(comment.userId ?? 'unknown', comment.userName),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 评论输入框
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    readOnly: !_isCommentFieldReady,
                    onTap: _handleCommentTap,
                    decoration: InputDecoration(
                      hintText: '写下你的评论...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.playButton),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 评论项组件
class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback onReport;
  final VoidCallback onBlockUser;

  const CommentItem({Key? key, required this.comment, required this.onReport, required this.onBlockUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(comment.userAvatar),
              ),
              SizedBox(width: 8),
              Text(
                comment.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Text(
                comment.timeAgo,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              // 屏蔽用户按钮 - 只对非当前用户的评论显示
              if (!UserService.isCurrentUser(comment.userId ?? 'unknown'))
                GestureDetector(
                  onTap: onBlockUser,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Text(
                      '屏蔽',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              if (!UserService.isCurrentUser(comment.userId ?? 'unknown'))
                SizedBox(width: 8),
              // 举报按钮 - 只对非当前用户的评论显示
              if (!UserService.isCurrentUser(comment.userId ?? 'unknown'))
                GestureDetector(
                  onTap: onReport,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Text(
                      '举报',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text(
              comment.content,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Divider(height: 16),
        ],
      ),
    );
  }
} 