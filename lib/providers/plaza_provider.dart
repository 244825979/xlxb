import 'package:flutter/material.dart';
import '../models/plaza_post.dart';
import '../models/comment.dart';
import '../utils/mock_data.dart';
import '../services/storage_service.dart';
import '../services/block_service.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'profile_provider.dart';
import '../models/voice_record.dart';
import '../services/user_service.dart';

class PlazaProvider extends ChangeNotifier {
  // 状态变量
  bool _isLoading = false;
  List<PlazaPost> _posts = [];
  bool _isBrowseMode = true; // 默认开启浏览模式
  final StorageService _storageService = StorageService();

  // Getters
  bool get isLoading => _isLoading;
  List<PlazaPost> get posts => _posts;
  bool get isBrowseMode => _isBrowseMode;

  // 初始化广场数据
  Future<void> initialize() async {
    print('Initializing PlazaProvider');
    _isLoading = true;
    notifyListeners();

    try {
      await _loadPlazaPosts();
      await _loadCommentCounts();
      print('Loaded ${_posts.length} posts');
    } catch (e, stackTrace) {
      print('广场初始化失败: $e');
      print('Stack trace: $stackTrace');
      _posts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载广场帖子
  Future<void> _loadPlazaPosts() async {
    try {
      print('Loading plaza posts');
      _posts = MockData.generateMockPlazaPosts();
      print('Generated ${_posts.length} mock posts');
      
      // 按时间排序，最新的在前面
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // 过滤已屏蔽的帖子
      await _filterBlockedPosts();
      print('After filtering blocked posts: ${_posts.length} posts');
      
      if (_posts.isEmpty) {
        print('Warning: No posts were generated!');
        final now = DateTime.now();
        _posts.add(PlazaPost(
          id: 'default_post',
          userId: 'default_user',
          userName: '心声助手',
          userAvatar: 'assets/images/avatars/default_avatar.png',
          content: '欢迎来到心声广场！这里是分享心声的地方。',
          createdAt: now,
          isVirtual: true,
          moodScore: 8.0,
        ));
      }
    } catch (e, stackTrace) {
      print('加载广场帖子失败: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    print('Refreshing plaza posts...');
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadPlazaPosts();
      await _loadCommentCounts();
      print('Refresh completed. Posts count: ${_posts.length}');
    } catch (e) {
      print('刷新失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换帖子喜欢状态
  void toggleLike(String postId, BuildContext context) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newLikeStatus = !post.isLiked;
      
      // 更新广场帖子状态
      _posts[index] = post.copyWith(isLiked: newLikeStatus);
      
      // 同步到用户个人资料
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      if (newLikeStatus) {
        // 转换为VoiceRecord格式
        final voiceRecord = _convertPlazaPostToVoiceRecord(post);
        profileProvider.addLikedPost(voiceRecord);
      } else {
        profileProvider.removeLikedPost(postId);
      }
      
      notifyListeners();
    }
  }

  // 将广场帖子转换为语音记录格式
  VoiceRecord _convertPlazaPostToVoiceRecord(PlazaPost post) {
    return VoiceRecord(
      id: post.id,
      title: post.userName,
      description: post.content,
      voicePath: post.imageUrl ?? 'plaza_${post.id}', // 使用图片路径或默认路径
      timestamp: post.createdAt,
      duration: Duration.zero,
      isFavorite: true,
      moodScore: post.moodScore,
      userAvatar: post.userAvatar, // 添加用户头像
      imageUrl: post.imageUrl, // 添加图片URL
    );
  }

  // 添加评论
  Future<bool> addComment(String postId, String commentText) async {
    try {
      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: postId,
        userId: UserService.getCurrentUserId(), // 添加当前用户ID
        userName: '我',
        userAvatar: 'assets/images/head_image/head_1.jpeg',
        content: commentText,
        createdAt: DateTime.now(),
      );

      // 保存评论到存储
      final success = await _storageService.addComment(postId, comment);
      if (success) {
        // 更新帖子的评论数量
        await _updatePostCommentCount(postId);
        return true;
      }
      return false;
    } catch (e) {
      print('添加评论失败: $e');
      return false;
    }
  }

  // 更新帖子评论数量
  Future<void> _updatePostCommentCount(String postId) async {
    try {
      final commentCount = await _storageService.getCommentCountForPost(postId);
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(commentCount: commentCount);
        notifyListeners();
      }
    } catch (e) {
      print('更新评论数量失败: $e');
    }
  }

  // 获取帖子的评论
  Future<List<Comment>> getCommentsForPost(String postId) async {
    return await _storageService.getComments(postId);
  }

  // 初始化时加载评论数量
  Future<void> _loadCommentCounts() async {
    try {
      for (int i = 0; i < _posts.length; i++) {
        final commentCount = await _storageService.getCommentCountForPost(_posts[i].id);
        _posts[i] = _posts[i].copyWith(commentCount: commentCount);
      }
      notifyListeners();
    } catch (e) {
      print('加载评论数量失败: $e');
    }
  }

  // 发布新动态
  Future<bool> publishPost({
    required String content,
    String? imagePath,
  }) async {
    try {
      // 获取当前用户信息
      final currentUserId = UserService.getCurrentUserId();
      
      // 生成随机心情分数
      final random = Random();
      final moodScore = 6.0 + random.nextDouble() * 4.0; // 6.0-10.0之间
      
      // 创建新动态
      final newPost = PlazaPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        userName: '心之声', // 当前用户昵称
        userAvatar: 'assets/images/head_image/head_1.jpeg',
        content: content,
        imageUrl: imagePath,
        createdAt: DateTime.now(),
        isVirtual: false,
        moodScore: moodScore,
        isLiked: false,
        commentCount: 0,
        reviewStatus: ReviewStatus.pending, // 新发布的动态设为审核中
      );
      
      // 添加到posts列表开头（最新的在前面）
      _posts.insert(0, newPost);
      
      // 通知UI更新
      notifyListeners();
      
      return true;
    } catch (e) {
      print('发布动态失败: $e');
      return false;
    }
  }

  // 添加回调函数来通知ProfileProvider
  Function(PlazaPost)? onPostPublished;

  // 设置发布回调
  void setPublishCallback(Function(PlazaPost) callback) {
    onPostPublished = callback;
  }

  // 修改发布方法，调用回调
  Future<bool> publishPostWithCallback({
    required String content,
    String? imagePath,
  }) async {
    try {
      // 获取当前用户信息
      final currentUserId = UserService.getCurrentUserId();
      
      // 生成随机心情分数
      final random = Random();
      final moodScore = 6.0 + random.nextDouble() * 4.0; // 6.0-10.0之间
      
      // 创建新动态
      final newPost = PlazaPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        userName: '心之声', // 当前用户昵称
        userAvatar: 'assets/images/head_image/head_1.jpeg',
        content: content,
        imageUrl: imagePath,
        createdAt: DateTime.now(),
        isVirtual: false,
        moodScore: moodScore,
        isLiked: false,
        commentCount: 0,
        reviewStatus: ReviewStatus.pending, // 新发布的动态设为审核中
      );
      
      // 添加到posts列表开头（最新的在前面）
      _posts.insert(0, newPost);
      
      // 通知ProfileProvider有新动态发布
      if (onPostPublished != null) {
        onPostPublished!(newPost);
      }
      
      // 通知UI更新
      notifyListeners();
      
      return true;
    } catch (e) {
      print('发布动态失败: $e');
      return false;
    }
  }

  // 生成随机用户昵称
  String _generateRandomUserName(Random random) {
    // 简约大方的昵称列表（3-6个字）
    final nicknames = [
      // 3个字
      '星河梦', '月光蓝', '清晨雨', '夜风吟', '春暖花', '秋叶黄',
      '云淡风', '花开时', '雪花飞', '海浪声', '山间风', '林深处',
      '晨曦光', '暮色沉', '微风轻', '细雨绵', '阳光暖', '星光闪',
      
      // 4个字
      '温柔晚风', '清晨阳光', '夜色温柔', '微风徐来', '花开半夏',
      '云卷云舒', '岁月静好', '时光荏苒', '浅笑安然', '静水流深',
      '春风十里', '秋水伊人', '梦里花开', '星河璀璨', '月色如水',
      '山河无恙', '岁月如歌', '清风明月', '淡然若水', '素雅如兰',
      
      // 5个字
      '温柔的月光', '清晨的露珠', '夜晚的星空', '微风的轻抚',
      '花开的声音', '雨后的彩虹', '阳光的温暖', '大海的呼唤',
      '山间的清风', '林中的鸟鸣', '溪水的歌声', '春天的脚步',
      '秋天的落叶', '冬日的暖阳', '夏夜的虫鸣', '云朵的影子',
      
      // 6个字
      '温柔的夜色里', '清晨第一缕光', '微风轻抚大地', '花开满园春色',
      '星河璀璨夜空', '月光洒向人间', '阳光穿过云层', '雨后清新空气',
      '山川湖海之间', '时光静好如初', '岁月温柔以待', '梦想照进现实',
    ];
    
    return nicknames[random.nextInt(nicknames.length)];
  }

  // 切换浏览模式
  void toggleBrowseMode() {
    _isBrowseMode = !_isBrowseMode;
    notifyListeners();
  }

  // 屏蔽帖子
  Future<void> blockPost(String postId) async {
    try {
      await BlockService.blockPost(postId);
      // 从当前列表中移除被屏蔽的帖子
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      print('屏蔽帖子失败: $e');
    }
  }

  // 过滤已屏蔽的帖子（在加载时调用）
  Future<void> _filterBlockedPosts() async {
    try {
      // 过滤被屏蔽的帖子
      _posts = await BlockService.filterBlockedPosts(_posts, (post) => post.id);
      // 过滤被屏蔽用户的内容
      _posts = await BlockService.filterBlockedUserContent(_posts, (post) => post.userId);
    } catch (e) {
      print('过滤屏蔽帖子失败: $e');
    }
  }
} 