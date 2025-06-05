app功能：声音记录、AI语音助手、每日情绪语录、声音树洞、情绪分析工具、语音日记、声音冥想

app名称：心声日记  
1. 首页：声音日历 / 今日心情
    * 展示每日语音卡片（虚拟语音）
    * 模拟声音日记/播放记录
    * 推荐心情语录（每日变化）
2. 广场：语音树洞 / 声音广场
    * 虚拟用户语音动态（录音 + 图文）
    * 浏览模式，禁止评论/互动
3. AI语音助手
    * 录音/语音输入后 AI 反馈
    * 功能：情绪分析、轻度陪聊、语音转文字
4. 声音档案（我的）
    * 个性声音画像（可编辑昵称、语音签名）
    * 心情分析图谱（图表展示）
    * 浏览记录、语音喜好
5. 设置
    * 用户协议 / 隐私协议
    * App 使用说明
    * 举报与封禁申诉通道

主色调：#D7EBFF
白色背景
语言：中文
屏幕：竖屏

# 心声日记 Flutter App

## 项目概述

心声日记是一个专注于语音记录和情感分享的移动应用，提供语音日记记录、AI语音助手对话、声音社区广场和个人档案管理等功能。

## 核心功能需求

### 1. 首页 (Home)
- 显示当日心情状态
- 语音播放器界面（播放/暂停、进度条）
- 每日心情语录展示
- 虚拟语音头像显示

### 2. 声音树洞 (Plaza)
- 展示用户分享的语音内容
- 支持语音播放
- 显示用户头像、昵称、发布时间
- 内容卡片式布局

### 3. AI语音助手 (Messages)
- 聊天界面
- 支持语音消息发送和播放
- AI回复模拟
- 消息时间戳

### 4. 个人档案 (Archive)
- 个人信息展示
- 心情分析图谱（周数据柱状图）
- 历史语音记录列表
- 收藏功能

## 技术架构

### 架构模式
采用简单的分层架构：
- **UI Layer**: 页面组件和UI控件
- **Business Layer**: 业务逻辑和状态管理
- **Data Layer**: 本地数据存储和模型

### 状态管理
- 使用 `setState` 进行局部状态管理
- 使用 `ChangeNotifier` + `Provider` 进行全局状态管理

### 数据存储
- `shared_preferences`: 用户设置、语音记录元数据
- 本地文件系统: 语音文件存储

## 文件结构

```
lib/
├── main.dart                      # 应用入口
├── app.dart                       # 应用配置
├── constants/
│   ├── app_colors.dart           # 颜色常量
│   ├── app_strings.dart          # 文本常量
│   └── app_assets.dart           # 资源路径常量
├── models/
│   ├── voice_record.dart         # 语音记录模型
│   ├── user_profile.dart         # 用户资料模型
│   ├── plaza_post.dart           # 广场帖子模型
│   ├── chat_message.dart         # 聊天消息模型
│   └── mood_data.dart            # 心情数据模型
├── services/
│   ├── audio_service.dart        # 音频服务
│   ├── storage_service.dart      # 本地存储服务
│   └── data_service.dart         # 数据管理服务
├── providers/
│   ├── home_provider.dart        # 首页状态管理
│   ├── plaza_provider.dart       # 广场状态管理
│   ├── chat_provider.dart        # 聊天状态管理
│   └── profile_provider.dart     # 个人档案状态管理
├── screens/
│   ├── main_screen.dart          # 主屏幕（底部导航）
│   ├── home_screen.dart          # 首页
│   ├── plaza_screen.dart         # 声音树洞
│   ├── chat_screen.dart          # AI语音助手
│   └── profile_screen.dart       # 个人档案
├── widgets/
│   ├── voice_player.dart         # 语音播放器组件
│   ├── voice_recorder.dart       # 语音录制组件
│   ├── mood_chart.dart           # 心情图表组件
│   ├── plaza_card.dart           # 广场卡片组件
│   ├── chat_bubble.dart          # 聊天气泡组件
│   └── bottom_navigation.dart    # 底部导航组件
└── utils/
    ├── audio_utils.dart          # 音频工具类
    ├── date_utils.dart           # 日期工具类
    └── mock_data.dart            # 模拟数据
```

## 核心模型定义

### VoiceRecord
```dart
class VoiceRecord {
  final String id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final bool isFavorite;
  final String? description;
}
```

### UserProfile
```dart
class UserProfile {
  final String id;
  final String name;
  final String avatar;
  final String signature;
  final List<VoiceRecord> records;
}
```

### PlazaPost
```dart
class PlazaPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final String? voiceFilePath;
  final Duration? voiceDuration;
  final DateTime createdAt;
  final bool isVirtual;
}
```

### ChatMessage
```dart
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? voiceFilePath;
  final Duration? voiceDuration;
  final bool isVoiceMessage;
}
```

### MoodData
```dart
class MoodData {
  final DateTime date;
  final double moodScore;
  final String moodDescription;
}
```

## 实现计划

### 第一阶段：基础框架
1. **项目初始化**
   - 创建Flutter项目
   - 配置依赖包
   - 设置基础目录结构

2. **UI框架搭建**
   - 实现底部导航栏
   - 创建四个主要页面框架
   - 设置应用主题和颜色

3. **基础组件开发**
   - 语音播放器组件
   - 卡片布局组件
   - 基础UI控件

### 第二阶段：首页功能
1. **首页布局**
   - 头部标题和设置图标
   - 今日心情展示区域
   - 语音播放器界面
   - 每日语录卡片

2. **状态管理**
   - HomeProvider实现
   - 语音播放状态管理
   - 数据持久化

### 第三阶段：声音树洞
1. **广场页面**
   - 帖子列表展示
   - 卡片式布局
   - 语音播放功能

2. **数据管理**
   - 模拟用户数据
   - PlazaProvider实现
   - 本地头像资源管理

### 第四阶段：AI语音助手
1. **聊天界面**
   - 消息列表展示
   - 聊天气泡组件
   - 输入框和录音按钮

2. **语音功能**
   - 录音功能实现
   - 语音播放功能
   - AI回复模拟

### 第五阶段：个人档案
1. **档案页面**
   - 个人信息展示
   - 心情图表组件
   - 历史记录列表

2. **数据可视化**
   - 周心情数据图表
   - 统计数据展示

### 第六阶段：优化完善
1. **性能优化**
   - 页面切换动画
   - 语音文件管理优化
   - 内存使用优化

2. **用户体验**
   - 错误处理
   - 加载状态
   - 交互反馈

## 关键技术点

### 音频处理
- 使用 `audioplayers` 进行音频播放
- 使用 `flutter_sound` 进行录音功能
- 音频文件本地存储管理

### 数据持久化
- `shared_preferences` 存储用户设置和元数据
- 文件系统存储音频文件
- JSON序列化存储复杂数据结构

### UI设计
- 仿iPhone界面设计
- 使用渐变背景和卡片阴影
- 自定义动画效果

## 依赖包列表

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  audioplayers: ^5.2.1
  flutter_sound: ^9.2.13
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
  fl_chart: ^0.65.0
```

## 资源文件

### 本地图片资源
```
assets/
├── images/
│   ├── avatars/
│   │   ├── user_1.png
│   │   ├── user_2.png
│   │   ├── user_3.png
│   │   └── default_avatar.png
│   └── backgrounds/
│       └── mood_bg.png
└── audio/
    └── sample_voice.m4a
```

这个架构设计注重低耦合度，每个模块职责清晰，便于维护和扩展。通过Provider模式管理状态，使用服务层封装业务逻辑，确保代码的可测试性和可维护性。
