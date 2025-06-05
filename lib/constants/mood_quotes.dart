import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 心情语录数据模型
class QuoteData {
  final String id;
  final String content;

  const QuoteData({
    required this.id,
    required this.content,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuoteData && other.content == content;
  }

  @override
  int get hashCode => content.hashCode;
}

/// 心情语录常量类
class MoodQuotes {
  /// 原始语录文本列表
  static const List<String> _rawQuotes = [
    '生活就像一场旅行，重要的不是目的地，而是沿途的风景和内心的感受。',
    '每一个清晨都是新的开始，带着希望迎接日出的温暖，让阳光洒满心房。',
    '保持一颗平静的心，慢慢体会生活中每一个细微而美好的瞬间与感动。',
    '生命中的每一刻都值得珍惜，无论是欢笑还是泪水，都是珍贵的记忆。',
    '愿你保持一颗童心，对世界充满好奇，对生活充满热情，发现美好。',
    '在繁忙的生活中，别忘了停下脚步，聆听内心最真实而温暖的声音。',
    '把温暖的记忆收进心底，让美好的期待住进明天，温暖前行的路程。',
    '生活中的小确幸，都是上天赐予我们最珍贵的礼物，值得用心珍惜。',
    '愿你的心灵如月光般皎洁，如春风般温柔，在平凡中遇见诗意美好。',
    '在人生的旅途中，保持乐观的态度，相信美好终会如期而至到来。',
    '生活是一首动人的诗，需要我们用心谱写，用爱演绎每一个音符。',
    '愿你的世界永远充满色彩，内心永远保持希望，遇见最美的风景。',
    '在寂静的夜晚，让思绪随着星光流淌，感受内心深处的平静安详。',
    '心若向阳，生命便不会黯淡，用积极的心态面对每一天的挑战。',
    '用温柔的心看世界，用坚定的步伐走向美好的未来，传递温暖。',
    '生活中的每一个微笑，都是内心小太阳绽放的温暖力量和美好。',
    '愿你如清晨的花朵，绽放生命的芬芳，在平凡日子里散发美丽光彩。',
    '心存感激，生活处处是美好，用感恩的眼光看世界的每一份温暖。',
    '让心灵去旅行，让思绪去飞翔，给自己一片自由的天空和梦想。',
    '保持一颗宁静的心，欣赏生活的美好，在平淡中发现真正的幸福。',
    '愿你的生活如诗如画，充满温暖与惊喜，每一刻都值得被温柔以待。',
    '在时光的长河里，静静聆听内心的声音，感受岁月沉淀的温暖美好。',
    '生命的美好，在于发现与感受每一个瞬间的珍贵意义和深刻内涵。',
    '用心感受每一刻，珍惜每一天，让生活中的点滴都成为美好回忆。',
    '愿你的心事轻如云淡风轻，内心保持纯净与美好，遇见更美的自己。',
    '在平凡中发现美好，在简单中寻找快乐，体会生活最真实的真谛。',
    '生活的真谛在于知足与感恩，珍惜拥有的每一份美好和温暖瞬间。',
    '愿你的心灵永远保持纯净，如清泉般澄澈，如白云般自在悠然。',
    '用爱与温暖装点生活的每一天，让善意和美好成为生活的主旋律。',
    '在岁月静好中安然前行，让心灵在时光里慢慢沉淀，遇见最好的自己。',
    '让心灵沐浴在阳光里，用积极的心态迎接每一天，拥抱美好生活。',
    '生活的美好在于懂得珍惜当下，专注于此刻的温暖感受和真实体验。',
    '愿你的笑容如春日般温暖，能够照亮身边人的世界，传递爱的力量。',
    '在生命的旅途中，通过每一次经历和成长，遇见内心最好的自己。',
    '用善良的心对待世界，用坚强的心面对人生，让温柔成为前行力量。',
    '生活中的每一天都值得好好珍惜，都是生命中不可重复的珍贵时光。',
    '愿你的心事都能被温柔以待，在这个世界上总有美好在路上等待。',
    '在平淡中寻找幸福，在简单中体会快乐，让心灵回归最初的纯真。',
    '让心灵找到归属，让生命绽放光彩，在浩瀚世界中活出精彩样子。',
    '用感恩的心看世界，用平和的心过生活，在宁静中获得内心安详。',
    '愿你的生活充满诗意与温暖，每个平凡的日子都能散发美丽光芒。',
    '在时光流转中保持内心的平静，让心灵在岁月里找到真正的自己。',
    '生命的意义在于创造与分享，用自己的方式传递温暖和爱的力量。',
    '愿你的心田永远春暖花开，无论经历什么都保持内心的美好希望。',
    '在生活的点滴中寻找属于自己的幸福，珍惜每个温暖而美好的惊喜。',
    '用温暖的心迎接每一天，让积极乐观成为生活的底色，传递正能量。',
    '让心灵去感受，让生命去绽放，在感受中成长，在绽放中找到意义。',
    '在岁月静好中遇见最美的自己，通过生活历练发现内心美丽的样子。',
    '生活的真谛在于懂得与珍惜，学会欣赏身边的每一份美好和感动。',
    '愿你的心灵永远充满阳光，无论遇到什么都保持明亮温暖的希望。',
  ];

  /// 生成内容的唯一ID
  static String _generateId(String content) {
    final bytes = utf8.encode(content);
    final digest = md5.convert(bytes);
    return digest.toString().substring(0, 8); // 使用前8位作为ID
  }

  /// 去重并生成带ID的语录列表
  static List<QuoteData> get officialQuotes {
    final Set<String> seenContents = <String>{};
    final List<QuoteData> uniqueQuotes = [];
    
    for (final quote in _rawQuotes) {
      final trimmedQuote = quote.trim();
      if (trimmedQuote.isNotEmpty && !seenContents.contains(trimmedQuote)) {
        seenContents.add(trimmedQuote);
        uniqueQuotes.add(QuoteData(
          id: _generateId(trimmedQuote),
          content: trimmedQuote,
        ));
      }
    }
    
    return uniqueQuotes;
  }

  /// 获取每日心情语录
  /// 根据日期返回固定的语录，确保每天显示相同的语录
  static String getDailyQuote() {
    final quotes = officialQuotes;
    final today = DateTime.now();
    final index = today.day % quotes.length;
    return quotes[index].content;
  }

  /// 根据ID获取语录
  static QuoteData? getQuoteById(String id) {
    try {
      return officialQuotes.firstWhere((quote) => quote.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有语录内容列表（兼容性方法）
  static List<String> get allQuoteContents {
    return officialQuotes.map((quote) => quote.content).toList();
  }
} 