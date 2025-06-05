import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepseekService {
  static const String _baseUrl = 'https://api.deepseek.com/chat/completions';
  static const String _apiKey = 'sk-baa41b59556440d9b82e4e185033db16';

  Future<String> getChatResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: utf8.encode(jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant. Please respond in Chinese.'},
            {'role': 'user', 'content': userMessage}
          ],
          'stream': false,
          'temperature': 0.7,
          'max_tokens': 1000
        })),
      );

      if (response.statusCode == 200) {
        // 确保响应内容是UTF-8编码
        final decodedResponse = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(decodedResponse);
        
        if (jsonResponse['choices'] != null && 
            jsonResponse['choices'].isNotEmpty && 
            jsonResponse['choices'][0]['message'] != null) {
          
          final content = jsonResponse['choices'][0]['message']['content'];
          // 验证返回的内容是否为有效的UTF-8字符串
          if (content != null && utf8.encode(content).isNotEmpty) {
            return content;
          }
        }
        throw Exception('Invalid response format from DeepSeek API');
      } else {
        print('DeepSeek API error: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
        throw Exception('Failed to get response from DeepSeek API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling DeepSeek API: $e');
      if (e.toString().contains('FormatException') || 
          e.toString().contains('Encoding') || 
          e.toString().contains('Unicode')) {
        return '抱歉，我暂时无法正确处理响应内容。请稍后再试。';
      }
      return '抱歉，我现在遇到了一些问题。请稍后再试。';
    }
  }

  // 用于调试的辅助方法
  void _printResponseDetails(http.Response response) {
    try {
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Raw response body: ${response.body}');
      print('UTF-8 decoded body: ${utf8.decode(response.bodyBytes)}');
    } catch (e) {
      print('Error printing response details: $e');
    }
  }
} 