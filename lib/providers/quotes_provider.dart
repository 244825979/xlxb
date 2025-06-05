import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import 'profile_provider.dart';
import 'package:flutter/material.dart';

class QuotesProvider extends ChangeNotifier {
  final Set<String> _likedQuotes = {};

  bool isQuoteLiked(String quote) => _likedQuotes.contains(quote);

  void toggleLike(String quoteContent, BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final now = DateTime.now();
    
    if (_likedQuotes.contains(quoteContent)) {
      _likedQuotes.remove(quoteContent);
      // 从个人中心移除喜欢的语录
      final quoteId = 'quote_${quoteContent.hashCode}';
      profileProvider.removeLikedQuote(quoteId);
    } else {
      _likedQuotes.add(quoteContent);
      // 添加到个人中心的喜欢语录
      final quote = Quote(
        id: 'quote_${quoteContent.hashCode}',
        content: quoteContent,
        timestamp: now,
        isFavorite: true,
        isOfficial: true,
      );
      profileProvider.addLikedQuote(quote);
    }
    notifyListeners();
  }
} 