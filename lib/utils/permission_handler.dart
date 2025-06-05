import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  /// 请求相册权限
  static Future<bool> requestPhotoPermission() async {
    PermissionStatus status = await Permission.photos.status;
    if (status.isDenied) {
      status = await Permission.photos.request();
    }
    return status.isGranted;
  }

  /// 请求麦克风权限
  static Future<bool> requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  /// 请求存储权限
  static Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  /// 检查并请求所有必要权限
  static Future<Map<Permission, bool>> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.microphone,
      Permission.storage,
    ].request();

    return Map.fromEntries(
      statuses.entries.map(
        (e) => MapEntry(e.key, e.value.isGranted),
      ),
    );
  }
} 