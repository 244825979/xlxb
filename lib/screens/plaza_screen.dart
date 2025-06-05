import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/plaza_provider.dart';
import '../screens/post_detail_screen.dart';
import '../screens/image_view_screen.dart';
import '../screens/publish_post_screen.dart';
import '../widgets/plaza_browse_card.dart';
import '../widgets/report_dialog.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';

class PlazaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<PlazaProvider>(
          builder: (context, provider, child) {
            print('Building PlazaScreen - Posts count: ${provider.posts.length}');
            print('Loading state: ${provider.isLoading}');
            print('Browse mode: ${provider.isBrowseMode}');
            
            return Column(
              children: [
                // 标题栏
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        AppStrings.plazaTitle,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      // 发布按钮
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublishPostScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.playButton,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '发布',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 切换模式按钮
                      GestureDetector(
                        onTap: () => provider.toggleBrowseMode(),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: provider.isBrowseMode 
                                ? AppColors.playButton.withOpacity(0.1)
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: provider.isBrowseMode 
                                ? Border.all(color: AppColors.playButton, width: 1)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                provider.isBrowseMode 
                                    ? Icons.view_list 
                                    : Icons.grid_view,
                                size: 16,
                                color: provider.isBrowseMode 
                                    ? AppColors.playButton 
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                provider.isBrowseMode ? AppStrings.listMode : AppStrings.browseMode,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: provider.isBrowseMode 
                                      ? AppColors.playButton 
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 帖子列表/网格
                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.playButton),
                          ),
                        )
                      : provider.posts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.nature_people,
                                    size: 64,
                                    color: AppColors.textLight,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '暂无内容',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: provider.refresh,
                              color: AppColors.playButton,
                              child: provider.isBrowseMode
                                  ? _buildGridView(provider)
                                  : _buildListView(provider),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 构建网格视图（浏览模式）- 改为瀑布流
  Widget _buildGridView(PlazaProvider provider) {
    return MasonryGridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      itemCount: provider.posts.length,
      itemBuilder: (context, index) {
        final post = provider.posts[index];
        return PlazaBrowseCard(
          post: post,
          onLike: () => provider.toggleLike(post.id, context),
        );
      },
    );
  }

  // 构建列表视图（普通模式）
  Widget _buildListView(PlazaProvider provider) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: provider.posts.length,
      itemBuilder: (context, index) {
        final post = provider.posts[index];
        print('Building post $index: ${post.content}');
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(post.userAvatar),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post.userName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // 审核中标识
                              if (post.isUnderReview && UserService.isCurrentUser(post.userId)) ...[
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
                            post.formattedCreatedAt,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // 内容
                Text(
                  post.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
                
                // 图片内容
                if (post.hasImage) ...[
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewScreen(
                            imageUrl: post.imageUrl!,
                          ),
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 4/3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildImageWidget(post.imageUrl!),
                      ),
                    ),
                  ),
                ],
                
                // 互动区域
                SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => provider.toggleLike(post.id, context),
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: post.isLiked ? Colors.red : AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '喜欢',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: post.isLiked ? Colors.red : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '评论${post.commentCount > 0 ? '(${post.commentCount})' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // 举报按钮
                    GestureDetector(
                      onTap: () => _showReportDialog(context, post),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '举报',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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

  // 构建图片显示组件
  Widget _buildImageWidget(String imagePath) {
    // 检查是否为本地文件路径
    if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
      // 本地文件
      return Image.file(
        File(imagePath.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.textLight.withOpacity(0.3),
            child: Icon(
              Icons.broken_image,
              color: AppColors.textLight,
              size: 32,
            ),
          );
        },
      );
    } else {
      // Asset图片
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.textLight.withOpacity(0.3),
            child: Icon(
              Icons.broken_image,
              color: AppColors.textLight,
              size: 32,
            ),
          );
        },
      );
    }
  }

  // 显示举报对话框
  void _showReportDialog(BuildContext context, post) {
    final reportService = ReportService();
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetContent: post.content,
        targetType: 'post',
        targetId: reportService.generateTargetId(post.content),
      ),
    );
  }
} 