import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../services/in_app_purchase_service.dart';
import '../models/purchase_models.dart';
import 'vip_privileges_screen.dart';

class RechargeScreen extends StatefulWidget {
  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> with TickerProviderStateMixin {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  StreamSubscription<PurchaseResult>? _purchaseSubscription;
  late TabController _tabController;
  
  List<RechargeItem> _rechargeItems = [];
  List<VipPackage> _vipPackages = [];
  String? _selectedProductId;
  RechargeItem? _selectedRechargeItem;
  VipPackage? _selectedVipPackage;
  bool _isLoading = false;
  bool _isPurchasing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      animationDuration: Duration(milliseconds: 300),
    );
    _initializePurchaseService();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializePurchaseService() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      debugPrint('RechargeScreen: Starting purchase service initialization...');
      final success = await _purchaseService.initialize();
      debugPrint('RechargeScreen: Purchase service initialization result: $success');
      
      if (success) {
        _rechargeItems = _purchaseService.getRechargeItems();
        _vipPackages = _purchaseService.getVipPackages();
        
        debugPrint('RechargeScreen: Loaded ${_rechargeItems.length} recharge items and ${_vipPackages.length} VIP packages');
        
        // 监听购买状态
        _purchaseSubscription = _purchaseService.purchaseStream.listen(_handlePurchaseResult);
        
        if (mounted) {
          setState(() => _isLoading = false);
        }
      } else {
        debugPrint('RechargeScreen: Purchase service not available');
        if (mounted) {
          setState(() => _isLoading = false);
          // 在生产环境中才显示服务不可用的错误
          if (!kDebugMode) {
            _showErrorSnackBar('应用内购买服务当前不可用，请稍后再试');
          } else {
            _showErrorSnackBar('开发模式：应用内购买服务不可用，但可以测试模拟购买');
          }
        }
      }
    } catch (e) {
      debugPrint('RechargeScreen: Initialize purchase service error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        if (kDebugMode) {
          _showErrorSnackBar('开发模式初始化错误: $e');
        } else {
          _showErrorSnackBar('服务初始化失败，请检查网络连接后重试');
        }
      }
    }
  }

  void _handlePurchaseResult(PurchaseResult result) {
    setState(() => _isPurchasing = false);
    
    switch (result.status) {
      case CustomPurchaseStatus.success:
        _showSuccessDialog('购买成功！金币已到账');
        break;
      case CustomPurchaseStatus.failed:
        _showErrorSnackBar(result.message ?? '购买失败');
        break;
      case CustomPurchaseStatus.cancelled:
        _showErrorSnackBar('购买已取消');
        break;
      case CustomPurchaseStatus.restored:
        _showSuccessDialog('购买已恢复');
        break;
      case CustomPurchaseStatus.pending:
        setState(() => _isPurchasing = true);
        break;
      default:
        break;
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _selectRechargeItem(RechargeItem item) {
    setState(() {
      _selectedRechargeItem = item;
      _selectedVipPackage = null; // 清除VIP选择
      _selectedProductId = item.productId;
    });
  }
  
  void _selectVipPackage(VipPackage package) {
    setState(() {
      _selectedVipPackage = package;
      _selectedRechargeItem = null; // 清除充值选择
      _selectedProductId = package.productId;
    });
  }

  Future<void> _purchaseSelectedProduct() async {
    if (_selectedProductId == null) return;
    if (_isPurchasing) return;
    
    debugPrint('=== RechargeScreen: Starting purchase for $_selectedProductId ===');
    
    setState(() {
      _isPurchasing = true;
    });
    
    // 显示购买进度提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('正在调用苹果支付...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 3),
      ),
    );
    
    try {
      debugPrint('RechargeScreen: Calling purchaseService.buyProduct($_selectedProductId)');
      await _purchaseService.buyProduct(_selectedProductId!);
      debugPrint('RechargeScreen: buyProduct call completed, waiting for result');
    } catch (e) {
      debugPrint('RechargeScreen: Purchase call failed: $e');
      setState(() => _isPurchasing = false);
      _showErrorSnackBar('发起购买失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF0F5),
            Color(0xFFFFF8FA),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '充值中心',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            if (kDebugMode)
              IconButton(
                onPressed: () async {
                  _showErrorSnackBar('正在诊断App Store Connect配置...');
                  await _purchaseService.diagnoseAppStoreConnectConfig();
                  _showErrorSnackBar('诊断完成，请查看控制台日志');
                },
                icon: Icon(Icons.bug_report, color: AppColors.textSecondary),
                tooltip: '诊断App Store配置',
              ),
            if (kDebugMode)
              IconButton(
                onPressed: () {
                  final currentValue = InAppPurchaseService.forceUseMockPayment;
                  InAppPurchaseService.setForceUseMockPayment(!currentValue);
                  _showErrorSnackBar(!currentValue ? '已开启模拟支付模式' : '已关闭模拟支付模式');
                },
                icon: Icon(
                  InAppPurchaseService.forceUseMockPayment ? Icons.science : Icons.science_outlined,
                  color: InAppPurchaseService.forceUseMockPayment ? Colors.green : AppColors.textSecondary,
                ),
                tooltip: '开发模式：切换模拟支付',
              ),
            IconButton(
              onPressed: () => _purchaseService.restorePurchases(),
              icon: Icon(Icons.restore, color: AppColors.textSecondary),
              tooltip: '恢复购买',
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      '正在初始化充值服务...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : _rechargeItems.isEmpty && _vipPackages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '充值服务暂时不可用',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          kDebugMode 
                              ? '开发模式：可以测试模拟购买功能'
                              : '请检查网络连接后重试',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _initializePurchaseService,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '重试',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // 余额显示
                      _buildBalanceCard(),
                      
                      // Tab选择器
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: TextStyle(fontWeight: FontWeight.w600),
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: [
                            Tab(text: '金币充值'),
                            Tab(text: 'VIP会员'),
                          ],
                        ),
                      ),
                      
                      // Tab内容
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildRechargeTab(),
                            _buildVipTab(),
                          ],
                        ),
                      ),
                      
                      // 底部充值按钮
                      _buildBottomPurchaseButton(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '当前余额',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '9900',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '金币',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.monetization_on,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择充值金额',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Text(
                  '每次与心声助手对话消耗1个金币',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemCount: _rechargeItems.length,
            itemBuilder: (context, index) => _buildRechargeCard(_rechargeItems[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildVipTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIP会员特权',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14),
          ..._vipPackages.map((package) => _buildVipCard(package)).toList(),
        ],
      ),
    );
  }

  Widget _buildRechargeCard(RechargeItem item) {
    final isSelected = _selectedRechargeItem?.productId == item.productId;
    
    return GestureDetector(
      onTap: () => _selectRechargeItem(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 10,
              offset: Offset(0, isSelected ? 8 : 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.coins.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              Text(
                '金币',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.priceText,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVipCard(VipPackage package) {
    final isSelected = _selectedVipPackage?.productId == package.productId;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectVipPackage(package),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 15 : 10,
                offset: Offset(0, isSelected ? 8 : 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          package.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            package.duration,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ...package.benefits.map((benefit) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text(
                            benefit,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  package.priceText,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPurchaseButton() {
    final isEnabled = _selectedProductId != null && !_isPurchasing;
    String buttonText = '请选择充值档次';
    String? selectedItemInfo;
    
    if (_selectedRechargeItem != null) {
      selectedItemInfo = '${_selectedRechargeItem!.coins}金币 - ${_selectedRechargeItem!.priceText}';
      buttonText = '立即充值';
    } else if (_selectedVipPackage != null) {
      selectedItemInfo = 'VIP会员${_selectedVipPackage!.duration} - ${_selectedVipPackage!.priceText}';
      buttonText = '立即购买';
    }
    
    if (_isPurchasing) {
      buttonText = '处理中...';
    }
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedItemInfo != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '已选择：$selectedItemInfo',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: isEnabled ? _purchaseSelectedProduct : null,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.primary : Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
                boxShadow: isEnabled ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPurchasing) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 