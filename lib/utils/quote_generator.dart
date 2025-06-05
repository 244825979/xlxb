import '../models/daily_quote.dart';
import '../constants/mood_quotes.dart';
import 'dart:math';

class QuoteGenerator {
  static final List<String> _nicknames = [
    '微风', '晨曦', '云端', '星河', '雨滴',
    '暖阳', '月光', '花语', '静谧', '梦境',
    '心语', '光影', '清风', '海浪', '山谷',
  ];

  static String _getRandomNickname() {
    final random = Random();
    final adjectives = ['温柔的', '善良的', '快乐的', '阳光的', '可爱的', '安静的', '优雅的', '美好的'];
    final nickname = _nicknames[random.nextInt(_nicknames.length)];
    
    // 随机决定是否添加形容词
    if (random.nextBool()) {
      final adjective = adjectives[random.nextInt(adjectives.length)];
      return '$adjective$nickname'; // 4-8个字
    }
    return nickname; // 2个字
  }

  static List<DailyQuote> generateDailyQuotes(int count) {
    final officialQuotes = MoodQuotes.officialQuotes;
    final List<DailyQuote> quotes = [];
    final now = DateTime.now();
    final random = Random();
    
    // 确保不会重复使用相同的语录
    final Set<String> usedQuoteIds = <String>{};
    
    for (int i = 0; i < count && quotes.length < count; i++) {
      final date = now.subtract(Duration(days: i));
      
      // 从官方语录中随机选择一个未使用的语录
      final availableQuotes = officialQuotes.where(
        (quote) => !usedQuoteIds.contains(quote.id)
      ).toList();
      
      if (availableQuotes.isEmpty) {
        // 如果所有语录都用完了，重置已使用列表
        usedQuoteIds.clear();
        availableQuotes.addAll(officialQuotes);
      }
      
      final selectedQuote = availableQuotes[random.nextInt(availableQuotes.length)];
      usedQuoteIds.add(selectedQuote.id);
      
      quotes.add(DailyQuote(
        id: '${selectedQuote.id}_${date.millisecondsSinceEpoch}', // 组合ID确保唯一性
        date: date,
        content: selectedQuote.content,
        nickname: _getRandomNickname(),
        isOfficial: true,
      ));
    }
    
    return quotes;
  }

  /// 生成特定日期的语录（确保每天固定显示同一条语录）
  static DailyQuote generateDailyQuoteForDate(DateTime date) {
    final officialQuotes = MoodQuotes.officialQuotes;
    final index = date.day % officialQuotes.length;
    final selectedQuote = officialQuotes[index];
    
    return DailyQuote(
      id: '${selectedQuote.id}_daily_${date.year}_${date.month}_${date.day}',
      date: date,
      content: selectedQuote.content,
      nickname: '官方语录',
      isOfficial: true,
    );
  }
} 