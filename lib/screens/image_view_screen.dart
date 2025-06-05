import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'dart:io';

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewScreen({Key? key, required this.imageUrl}) : super(key: key);

  // 构建图片显示组件
  Widget _buildImageWidget() {
    // 检查是否为本地文件路径
    if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
      // 本地文件
      return Image.file(
        File(imageUrl.replaceFirst('file://', '')),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.withOpacity(0.3),
            child: Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 64,
            ),
          );
        },
      );
    } else {
      // Asset图片
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.withOpacity(0.3),
            child: Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 64,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏为黑色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: _buildImageWidget(),
        ),
      ),
    );
  }
} 