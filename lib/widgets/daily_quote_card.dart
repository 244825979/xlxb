import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../screens/quotes_screen.dart';
import '../providers/quotes_provider.dart';
import '../constants/app_strings.dart';
import '../constants/mood_quotes.dart';
import '../widgets/report_dialog.dart';
import '../services/report_service.dart';

class DailyQuoteCard extends StatelessWidget {
  final String? quote;

  const DailyQuoteCard({
    Key? key,
    this.quote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayQuote = quote ?? MoodQuotes.getDailyQuote();
    final reportService = ReportService();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Stack(
              children: [
                // 装饰背景
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                        AppColors.primary.withOpacity(0.0),
                      ],
                      stops: [0.0, 0.6, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // 标题内容
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.format_quote,
                          color: AppColors.playButton,
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '官方语录',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 语录内容
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 3,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                displayQuote,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  height: 1.8,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // 底部按钮和装饰
          LayoutBuilder(
            builder: (context, constraints) {
              // 获取屏幕宽度来判断是否需要调整布局
              final screenWidth = MediaQuery.of(context).size.width;
              final isSmallScreen = screenWidth < 375; // iPhone SE等小屏机型
              
              return Column(
                children: [
                  // 装饰文字单独一行
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12, 
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '愿你心怀暖阳',
                          style: TextStyle(
                            color: AppColors.playButton,
                            fontSize: isSmallScreen ? 11 : 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // 按钮组
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Consumer<QuotesProvider>(
                        builder: (context, provider, child) {
                          final isLiked = provider.isQuoteLiked(displayQuote);
                          return Container(
                            margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
                            child: Material(
                              color: isLiked ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => provider.toggleLike(displayQuote, context),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 10, 
                                    vertical: isSmallScreen ? 4 : 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? AppColors.favoriteRed : AppColors.textSecondary,
                                        size: isSmallScreen ? 14 : 16,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        isLiked ? '已喜欢' : '喜欢',
                                        style: TextStyle(
                                          color: isLiked ? AppColors.favoriteRed : AppColors.textSecondary,
                                          fontSize: isSmallScreen ? 10 : 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // 举报按钮
                      Container(
                        margin: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showReportDialog(context, displayQuote, reportService),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 10, 
                                vertical: isSmallScreen ? 4 : 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    color: AppColors.textSecondary,
                                    size: isSmallScreen ? 14 : 16,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    '举报',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isSmallScreen ? 10 : 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 查看更多按钮
                      Material(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QuotesScreen()),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 10, 
                              vertical: isSmallScreen ? 4 : 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '查看更多',
                                  style: TextStyle(
                                    color: AppColors.playButton,
                                    fontSize: isSmallScreen ? 10 : 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.playButton,
                                  size: isSmallScreen ? 10 : 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, String quoteContent, ReportService reportService) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetContent: quoteContent,
        targetType: 'quote',
        targetId: reportService.generateTargetId(quoteContent),
      ),
    );
  }
} 