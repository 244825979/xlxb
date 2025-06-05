import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/home_provider.dart';
import '../providers/plaza_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/profile_provider.dart';
import 'home_screen.dart';
import 'plaza_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  // 添加全局键，让其他页面可以访问MainScreen的状态
  static final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

  // 添加key参数
  const MainScreen({Key? key}) : super(key: key);

  // 添加静态方法，让其他页面可以切换到广场页
  static void switchToPlazaTab(BuildContext context) {
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState.switchToTab(1); // 广场页的索引是1
    }
  }

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    HomeScreen(),
    PlazaScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // 初始化所有Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      final plazaProvider = context.read<PlazaProvider>();
      final chatProvider = context.read<ChatProvider>();
      final profileProvider = context.read<ProfileProvider>();
      
      // 设置广场发布回调，同步更新个人中心
      plazaProvider.setPublishCallback((plazaPost) {
        profileProvider.addNewDynamicFromPlaza(plazaPost);
      });
      
      // 初始化所有Provider
      homeProvider.initialize();
      plazaProvider.initialize();
      chatProvider.initialize();
      profileProvider.initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 添加公共方法，让其他页面可以切换到指定标签
  void switchToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      _onTabTapped(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: MainScreen.mainScreenKey, // 设置全局键
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: AppStrings.navHome,
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.nature,
                  label: AppStrings.navPlaza,
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_outline,
                  label: AppStrings.navMessages,
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: AppStrings.navProfile,
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.playButton : AppColors.textLight,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.playButton : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 