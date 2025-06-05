import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/chat_provider.dart';
import '../utils/avatar_utils.dart';
import 'feedback_screen.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _loadingController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    // 初始化完成后滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<ChatProvider>(
          builder: (context, provider, child) {
            // 当收到新消息或开始输入时滚动到底部
            if (provider.messages.isNotEmpty || provider.isTyping) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            return Column(
              children: [
                // 标题栏
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(AvatarUtils.assistantAvatar),
                      ),
                      SizedBox(width: 12),
                      Text(
                        AppStrings.chatTitle,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FeedbackScreen()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [AppColors.softShadow],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.feedback_outlined,
                                color: AppColors.playButton,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '反馈',
                                style: TextStyle(
                                  color: AppColors.playButton,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 消息列表
                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.playButton),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.messages.length && provider.isTyping) {
                              return _buildTypingIndicator();
                            }
                            final message = provider.messages[index];
                            return _buildMessageBubble(message);
                          },
                        ),
                ),
                
                // 输入区域
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 文本输入框
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: !provider.isTyping,
                          decoration: InputDecoration(
                            hintText: provider.isTyping ? '助手正在回复中...' : AppStrings.inputHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty && !provider.isTyping) {
                              provider.sendTextMessage(text);
                              _textController.clear();
                              // 发送消息后滚动到底部
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToBottom();
                              });
                            }
                          },
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // 发送按钮
                      GestureDetector(
                        onTap: () {
                          if (!provider.isTyping) {
                            final text = _textController.text;
                            if (text.trim().isNotEmpty) {
                              provider.sendTextMessage(text);
                              _textController.clear();
                              // 发送消息后滚动到底部
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToBottom();
                              });
                            }
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: provider.isTyping ? AppColors.textSecondary : AppColors.playButton,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(AvatarUtils.assistantAvatar),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.softShadow],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoadingDot(),
                SizedBox(width: 4),
                _buildLoadingDot(delay: 0.2),
                SizedBox(width: 4),
                _buildLoadingDot(delay: 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDot({double delay = 0.0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1200),
      curve: Interval(delay, delay + 0.5, curve: Curves.easeInOut),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.playButton.withOpacity(0.3 + (0.7 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(message) {
    final isUser = message.isUser;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(AvatarUtils.assistantAvatar),
            ),
            SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.playButton : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.softShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  Text(
                    message.formattedTime,
                    style: TextStyle(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7) 
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(AvatarUtils.userAvatar),
            ),
          ],
        ],
      ),
    );
  }
} 