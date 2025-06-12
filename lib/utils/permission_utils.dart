import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionUtils {
  static Future<bool> checkAndRequestPermission(BuildContext context) async {
    // 检查网络权限
    if (await Permission.location.isDenied) {
      final status = await Permission.location.request();
      if (status.isDenied) {
        // 如果用户拒绝了权限，显示对话框解释为什么需要权限
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('需要网络权限'),
              content: const Text('为了提供更好的服务体验，我们需要访问网络。请在设置中开启网络权限。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await openAppSettings();
                  },
                  child: const Text('去设置'),
                ),
              ],
            ),
          );
        }
        return false;
      }
    }
    return true;
  }

  static Future<void> showPermissionDeniedDialog(BuildContext context, String permissionName) async {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('需要$permissionName权限'),
          content: Text('请在设置中开启$permissionName权限以继续使用该功能'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        ),
      );
    }
  }
} 