import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../services/block_service.dart';
import '../utils/mock_data.dart';
import '../models/plaza_post.dart';

class BlockedContentScreen extends StatefulWidget {
  @override
  _BlockedContentScreenState createState() => _BlockedContentScreenState();
}

class _BlockedContentScreenState extends State<BlockedContentScreen> {
  List<BlockedItem> _blockedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllBlockedContent();
  }

  Future<void> _loadAllBlockedContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _blockedItems.clear();
      
      // 获取屏蔽的帖子
      final blockedPostIds = await BlockService.getBlockedPosts();
      final allPosts = MockData.generateMockPlazaPosts();
      
      for (final postId in blockedPostIds) {
        final post = allPosts.firstWhere(
          (p) => p.id == postId,
          orElse: () => PlazaPost(
            id: postId,
            userId: 'unknown',
            userName: '未知用户',
            userAvatar: 'assets/images/head_image/head_1.jpeg',
            content: '已删除的内容',
            createdAt: DateTime.now(),
            isVirtual: false,
            moodScore: 0,
          ),
        );
        
        _blockedItems.add(BlockedItem(
          id: postId,
          type: BlockedType.post,
          title: post.userName,
          content: '已屏蔽该条动态内容',
          avatar: post.userAvatar,
          blockedAt: DateTime.now(),
          userId: post.userId,
        ));
      }

      // 获取屏蔽的用户
      final blockedUserIds = await BlockService.getBlockedUsers();
      Map<String, bool> addedUsers = {};
      
      for (final post in allPosts) {
        if (blockedUserIds.contains(post.userId) && !addedUsers.containsKey(post.userId)) {
          _blockedItems.add(BlockedItem(
            id: post.userId,
            type: BlockedType.user,
            title: post.userName,
            content: '已屏蔽此用户的所有内容',
            avatar: post.userAvatar,
            blockedAt: DateTime.now(),
            userId: post.userId,
          ));
          addedUsers[post.userId] = true;
        }
      }
      
      // 注意：评论屏蔽目前通过用户屏蔽实现，所以不单独显示

      // 按时间排序
      _blockedItems.sort((a, b) => b.blockedAt.compareTo(a.blockedAt));
      
    } catch (e) {
      print('加载屏蔽内容失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockItem(BlockedItem item) async {
    try {
      if (item.type == BlockedType.post) {
        await BlockService.unblockPost(item.id);
      } else if (item.type == BlockedType.user) {
        await BlockService.unblockUser(item.id);
      }
      
      // 重新加载列表
      await _loadAllBlockedContent();
      
      // 显示成功提示
      String message = '';
      if (item.type == BlockedType.post) {
        message = '已取消屏蔽动态';
      } else if (item.type == BlockedType.user) {
        message = '已取消屏蔽用户 "${item.title}"';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.playButton,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('取消屏蔽失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('取消屏蔽失败，请重试'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showUnblockDialog(BlockedItem item) {
    String title = '';
    String content = '';
    
    if (item.type == BlockedType.post) {
      title = '取消屏蔽动态';
      content = '确定要取消屏蔽这条动态吗？取消后您将重新看到此内容。';
    } else if (item.type == BlockedType.user) {
      title = '取消屏蔽用户';
      content = '确定要取消屏蔽用户 "${item.title}" 吗？取消后您将重新看到该用户的所有内容。';
    }

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
                color: AppColors.playButton,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
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
              onPressed: () {
                Navigator.of(context).pop();
                _unblockItem(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.playButton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                '确定取消屏蔽',
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

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            '屏蔽管理',
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
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.playButton),
                ),
              )
            : _blockedItems.isEmpty
                ? _buildEmptyState()
                : _buildBlockedList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: AppColors.textLight,
            ),
            SizedBox(height: 24),
            Text(
              '暂无屏蔽内容',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '您还没有屏蔽任何内容',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedList() {
    // 统计不同类型的数量
    final postCount = _blockedItems.where((item) => item.type == BlockedType.post).length;
    final userCount = _blockedItems.where((item) => item.type == BlockedType.user).length;
    
    return Column(
      children: [
        // 头部统计信息
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '共屏蔽了 ${_blockedItems.length} 项内容',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '动态: $postCount 条',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '用户: $userCount 个',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 屏蔽内容列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: _blockedItems.length,
            itemBuilder: (context, index) {
              final item = _blockedItems[index];
              return _buildBlockedItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlockedItem(BlockedItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部信息
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(item.avatar),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8),
                        // 类型标签
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTypeColor(item.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getTypeColor(item.type).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            _getTypeText(item.type),
                            style: TextStyle(
                              color: _getTypeColor(item.type),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatTime(item.blockedAt),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // 取消屏蔽按钮
              TextButton(
                onPressed: () => _showUnblockDialog(item),
                child: Text(
                  '取消屏蔽',
                  style: TextStyle(
                    color: AppColors.playButton,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // 内容预览
          Text(
            item.content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            maxLines: item.type == BlockedType.user ? 1 : 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(BlockedType type) {
    switch (type) {
      case BlockedType.post:
        return Colors.red;
      case BlockedType.user:
        return Colors.orange;
      case BlockedType.comment:
        return Colors.purple;
    }
  }

  String _getTypeText(BlockedType type) {
    switch (type) {
      case BlockedType.post:
        return '动态';
      case BlockedType.user:
        return '用户';
      case BlockedType.comment:
        return '评论';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚屏蔽';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前屏蔽';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前屏蔽';
    } else {
      return '${difference.inDays}天前屏蔽';
    }
  }
}

// 屏蔽类型枚举
enum BlockedType {
  post,    // 动态
  user,    // 用户
  comment, // 评论
}

// 屏蔽项目类
class BlockedItem {
  final String id;
  final BlockedType type;
  final String title;
  final String content;
  final String avatar;
  final DateTime blockedAt;
  final String userId;

  BlockedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.avatar,
    required this.blockedAt,
    required this.userId,
  });
} 