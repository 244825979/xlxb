import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class VipPrivilegesScreen extends StatefulWidget {
  @override
  _VipPrivilegesScreenState createState() => _VipPrivilegesScreenState();
}

class _VipPrivilegesScreenState extends State<VipPrivilegesScreen> {
  int selectedPlan = 0;
  
  final List<VipPlan> vipPlans = [
    VipPlan(
      title: '月度会员',
      duration: '1个月',
      price: 19.90,
      originalPrice: 29.90,
      savings: '立省10元',
      isPopular: false,
    ),
    VipPlan(
      title: '季度会员',
      duration: '3个月',
      price: 49.90,
      originalPrice: 89.70,
      savings: '立省39.8元',
      isPopular: true,
    ),
    VipPlan(
      title: '年度会员',
      duration: '12个月',
      price: 168.00,
      originalPrice: 358.80,
      savings: '立省190.8元',
      isPopular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF9C88FF),
            Color(0xFFFF6B9D),
            Color(0xFFFFF0F5),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'VIP会员特权',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    
                    // VIP特权展示
                    _buildVipPrivileges(),
                    
                    SizedBox(height: 30),
                    
                    // 套餐选择标题
                    Text(
                      '选择订阅套餐',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // VIP套餐选择
                    _buildVipPlans(),
                  ],
                ),
              ),
            ),
            
            // 底部开通按钮
            _buildSubscribeButton(),
          ],
        ),
      ),
    );
  }

  // 构建VIP特权展示
  Widget _buildVipPrivileges() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // VIP图标和标题
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFF8C00),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            'VIP会员特权',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: 8),
          
          Text(
            '开通会员，享受更多贴心服务',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          SizedBox(height: 24),
          
          // 特权列表
          _buildPrivilegeItem(
            icon: Icons.chat_bubble_outline,
            title: '免费与心声助手沟通',
            description: '无限次数与AI助手对话，不消耗金币',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  // 构建特权条目
  Widget _buildPrivilegeItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isHighlight,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? Color(0xFF9C88FF).withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isHighlight ? Border.all(
          color: Color(0xFF9C88FF).withOpacity(0.3),
          width: 1,
        ) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isHighlight ? Color(0xFF9C88FF) : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isHighlight ? Color(0xFF9C88FF) : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建VIP套餐选择
  Widget _buildVipPlans() {
    return Column(
      children: vipPlans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        final isSelected = selectedPlan == index;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPlan = index;
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Color(0xFFFFC600) : Colors.grey.withOpacity(0.2),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                    ? Color(0xFFFFC600).withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 20 : 10,
                  offset: Offset(0, isSelected ? 10 : 5),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFFFC600).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Color(0xFFFFC600) : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            plan.duration,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Color(0xFFFFC600).withOpacity(0.8) : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                '¥',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Color(0xFFFFC600) : Color(0xFFFF6B6B),
                                ),
                              ),
                              Text(
                                '${plan.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Color(0xFFFFC600) : Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '原价¥${plan.originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                plan.savings,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 构建开通按钮
  Widget _buildSubscribeButton() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFF8C00),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              if (selectedPlan >= 0 && selectedPlan < vipPlans.length) {
                _handleSubscribe();
              }
            },
            child: Center(
              child: Text(
                '立即开通VIP会员',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 处理开通VIP
  void _handleSubscribe() {
    final plan = vipPlans[selectedPlan];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '确认开通VIP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '您将开通 ${plan.title}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '支付金额：¥${plan.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现VIP开通逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('VIP开通功能开发中...'),
                  backgroundColor: Color(0xFFFFD700),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '确认支付',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// VIP套餐模型
class VipPlan {
  final String title;
  final String duration;
  final double price;
  final double originalPrice;
  final String savings;
  final bool isPopular;

  VipPlan({
    required this.title,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.savings,
    required this.isPopular,
  });
} 