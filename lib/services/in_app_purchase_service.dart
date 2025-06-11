import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../models/purchase_models.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final iap.InAppPurchase _inAppPurchase = iap.InAppPurchase.instance;
  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;
  
  // 购买状态通知
  final StreamController<PurchaseResult> _purchaseController = StreamController<PurchaseResult>.broadcast();
  Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  // 开发模式强制使用模拟支付开关
  static bool _forceUseMockPayment = false;
  static bool get forceUseMockPayment => _forceUseMockPayment;
  static void setForceUseMockPayment(bool value) {
    _forceUseMockPayment = value;
    debugPrint('Force use mock payment: $value');
  }

  // 充值商品ID列表
  static const List<String> _rechargeProductIds = [
    'lelele_12',
    'lelele_38', 
    'lelele_68',
    'lelele_98',
    'lelele_198',
    'lelele_298',
    'lelele_598',
  ];

  // VIP商品ID列表
  static const List<String> _vipProductIds = [
    'lelelevip68',
    'lelelevip168',
    'lelelevip399',
  ];

  // 所有商品ID
  static const List<String> _allProductIds = [
    ..._rechargeProductIds,
    ..._vipProductIds,
  ];

  bool _isInitialized = false;
  bool _isAvailable = false;
  List<iap.ProductDetails> _products = [];

  /// 初始化内购服务
  Future<bool> initialize() async {
    debugPrint('=== InAppPurchaseService: Starting initialization ===');
    
    if (_isInitialized) {
      debugPrint('Already initialized, returning: $_isAvailable');
      return _isAvailable;
    }

    try {
      debugPrint('Checking in-app purchase availability...');
      
      // 检查设备类型
      bool isRealDevice = !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') && 
                         !Platform.environment.containsKey('FLUTTER_TEST');
      
      debugPrint('Initializing on: ${isRealDevice ? "Real Device" : "Simulator"}');
      
      // 在真机上，严格检查Apple服务可用性
      if (isRealDevice) {
        _isAvailable = await _inAppPurchase.isAvailable();
        debugPrint('Apple In-App Purchase available on real device: $_isAvailable');
        
        if (!_isAvailable) {
          debugPrint('Apple In-App Purchase not available on real device');
          _isInitialized = true;
          return false;
        }
        
        // 设置购买监听
        _subscription = _inAppPurchase.purchaseStream.listen(
          _handlePurchaseUpdate,
          onError: (error) {
            debugPrint('Purchase stream error: $error');
            _purchaseController.add(PurchaseResult(
              status: CustomPurchaseStatus.failed,
              message: '购买过程中发生错误',
            ));
          },
        );

        // 在iOS上启用等待订单
        if (Platform.isIOS) {
          try {
            final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
                _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
            await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
          } catch (e) {
            debugPrint('StoreKit delegate setup failed: $e');
          }
        }

        // 加载商品信息
        await _loadProducts();
        
        _isInitialized = true;
        debugPrint('=== InAppPurchaseService: Real device initialization completed ===');
        return true;
      } else if (kDebugMode) {
        // 只有在模拟器或测试环境中才使用fallback
        try {
          _isAvailable = await _inAppPurchase.isAvailable();
          debugPrint('In-app purchase available: $_isAvailable');
        } catch (e) {
          debugPrint('Failed to check availability in debug mode: $e');
          _isAvailable = false;
        }
        
        // 在开发模式下，无论服务是否可用都允许继续
        debugPrint('Debug mode: Enabling service regardless of availability');
        _isAvailable = true;
        
        // 设置一个基础的Stream监听
        try {
          _subscription = _inAppPurchase.purchaseStream.listen(
            _handlePurchaseUpdate,
            onError: (error) {
              debugPrint('Purchase stream error: $error');
            },
          );
        } catch (e) {
          debugPrint('Failed to setup purchase stream, using empty stream: $e');
          _subscription = Stream<List<iap.PurchaseDetails>>.empty().listen(
            _handlePurchaseUpdate,
            onError: (error) {
              debugPrint('Purchase stream error (fallback): $error');
            },
          );
        }
        
        // 尝试加载商品信息
        try {
          await _loadProducts();
        } catch (e) {
          debugPrint('Product loading failed in debug mode: $e');
          _products = [];
        }
        
        _isInitialized = true;
        debugPrint('=== InAppPurchaseService: Debug mode initialization completed ===');
        return true;
        
      } else {
        // 生产环境的正常初始化
        _isAvailable = await _inAppPurchase.isAvailable();
        debugPrint('In-app purchase available: $_isAvailable');
        
        if (_isAvailable) {
          // 监听购买更新
          _subscription = _inAppPurchase.purchaseStream.listen(
            _handlePurchaseUpdate,
            onError: (error) {
              debugPrint('Purchase stream error: $error');
              _purchaseController.add(PurchaseResult(
                status: CustomPurchaseStatus.failed,
                message: '购买过程中发生错误',
              ));
            },
          );

          // 在iOS上启用等待订单
          if (Platform.isIOS) {
            try {
              final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
                  _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
              await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
            } catch (e) {
              debugPrint('StoreKit delegate setup failed: $e');
            }
          }

          // 加载商品信息
          await _loadProducts();
        }
        
        _isInitialized = true;
        debugPrint('=== InAppPurchaseService: Production initialization completed ===');
        return _isAvailable;
      }
      
    } catch (e) {
      debugPrint('=== InAppPurchaseService: Initialization failed: $e ===');
      
      // 最后的fallback
      if (kDebugMode) {
        debugPrint('Using final fallback mode in debug');
        _isInitialized = true;
        _isAvailable = true;
        _products = [];
        return true;
      }
      
      _isInitialized = true;
      _isAvailable = false;
      return false;
    }
  }

  /// 加载商品信息
  Future<void> _loadProducts() async {
    debugPrint('=== Loading product information ===');
    debugPrint('Querying product IDs: $_allProductIds');
    
    try {
      final iap.ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_allProductIds.toSet());
      
      debugPrint('Query response received:');
      debugPrint('  - Found products: ${response.productDetails.length}');
      debugPrint('  - Not found IDs: ${response.notFoundIDs}');
      debugPrint('  - Response error: ${response.error}');
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('❌ Products not found in App Store: ${response.notFoundIDs}');
        debugPrint('Please check App Store Connect configuration for these IDs');
      }
      
      _products = response.productDetails;
      debugPrint('✅ Successfully loaded ${_products.length} products from App Store');
      
      if (_products.isNotEmpty) {
        debugPrint('Product details:');
        for (var product in _products) {
          debugPrint('  - ID: ${product.id}');
          debugPrint('    Title: ${product.title}');
          debugPrint('    Price: ${product.price}');
          debugPrint('    Description: ${product.description}');
          debugPrint('    Currency: ${product.currencyCode}');
        }
      } else {
        debugPrint('⚠️ No products were found in App Store');
      }
      
    } catch (e) {
      debugPrint('❌ Failed to load products from App Store: $e');
      debugPrint('Error type: ${e.runtimeType}');
      _products = [];
      
      if (kDebugMode) {
        debugPrint('Debug mode: Will use mock products for purchase');
      }
    }
    debugPrint('=== Product loading completed ===');
  }

  /// 获取充值商品列表
  List<RechargeItem> getRechargeItems() {
    final rechargeData = [
      {'productId': 'lelele_12', 'price': 12.0, 'coins': 840},
      {'productId': 'lelele_38', 'price': 38.0, 'coins': 2660},
      {'productId': 'lelele_68', 'price': 68.0, 'coins': 4760},
      {'productId': 'lelele_98', 'price': 98.0, 'coins': 6860},
      {'productId': 'lelele_198', 'price': 198.0, 'coins': 13860},
      {'productId': 'lelele_298', 'price': 298.0, 'coins': 20860},
      {'productId': 'lelele_598', 'price': 598.0, 'coins': 41860},
    ];

    // 在调试模式下，即使服务初始化了也始终返回商品列表（用于测试）
    if (kDebugMode) {
      debugPrint('Debug mode: Returning mock recharge items for testing');
      return rechargeData.map((data) {
        return RechargeItem(
          productId: data['productId'] as String,
          title: '${data['coins']}金币',
          price: data['price'] as double,
          coins: data['coins'] as int,
          priceText: '￥${(data['price'] as double).toStringAsFixed(0)}',
          isPopular: false,
        );
      }).toList();
    }

    // 生产模式下，优先使用真实商品信息
    return rechargeData.map((data) {
      final product = _products.firstWhere(
        (p) => p.id == data['productId'],
        orElse: () => _createMockProduct(data['productId'] as String, data['price'] as double),
      );

      return RechargeItem(
        productId: data['productId'] as String,
        title: '${data['coins']}金币',
        price: data['price'] as double,
        coins: data['coins'] as int,
        priceText: '￥${(data['price'] as double).toStringAsFixed(0)}',
        isPopular: false,
      );
    }).toList();
  }

  /// 获取VIP套餐列表
  List<VipPackage> getVipPackages() {
    final vipData = [
      {'productId': 'lelelevip68', 'price': 68.0, 'duration': '1个月'},
      {'productId': 'lelelevip168', 'price': 168.0, 'duration': '3个月'},
      {'productId': 'lelelevip399', 'price': 399.0, 'duration': '12个月'},
    ];

    // 在调试模式下，即使服务初始化了也始终返回VIP套餐列表（用于测试）
    if (kDebugMode) {
      debugPrint('Debug mode: Returning mock VIP packages for testing');
      return vipData.map((data) {
        return VipPackage(
          productId: data['productId'] as String,
          title: 'VIP会员',
          price: data['price'] as double,
          duration: data['duration'] as String,
          priceText: '￥${(data['price'] as double).toStringAsFixed(0)}',
          isPopular: false,
          benefits: [
            '无限制与AI助手对话',
            '高级情感分析',
          ],
        );
      }).toList();
    }

    // 生产模式下，优先使用真实商品信息
    return vipData.map((data) {
      final product = _products.firstWhere(
        (p) => p.id == data['productId'],
        orElse: () => _createMockProduct(data['productId'] as String, data['price'] as double),
      );

      return VipPackage(
        productId: data['productId'] as String,
        title: 'VIP会员',
        price: data['price'] as double,
        duration: data['duration'] as String,
        priceText: '￥${(data['price'] as double).toStringAsFixed(0)}',
        isPopular: false,
        benefits: [
          '无限制与AI助手对话',
          '高级情感分析',
        ],
      );
    }).toList();
  }

  /// 创建模拟商品（用于测试）
  iap.ProductDetails _createMockProduct(String id, double price) {
    return iap.ProductDetails(
      id: id,
      title: id,
      description: id,
      price: '￥${price.toStringAsFixed(0)}',
      rawPrice: price,
      currencyCode: 'CNY',
    );
  }

  /// 购买商品
  Future<void> buyProduct(String productId) async {
    debugPrint('=== Starting purchase for product: $productId ===');
    
    if (!_isAvailable) {
      _purchaseController.add(PurchaseResult(
        status: CustomPurchaseStatus.failed,
        message: '应用内购买服务不可用',
      ));
      return;
    }

    // 发送pending状态
    _purchaseController.add(PurchaseResult(
      status: CustomPurchaseStatus.pending,
      productId: productId,
    ));

    // 检查是否是真机环境
    bool isRealDevice = !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') && 
                       !Platform.environment.containsKey('FLUTTER_TEST');
    
    debugPrint('=== Device Environment Check ===');
    debugPrint('SIMULATOR_DEVICE_NAME: ${Platform.environment['SIMULATOR_DEVICE_NAME']}');
    debugPrint('FLUTTER_TEST: ${Platform.environment['FLUTTER_TEST']}');
    debugPrint('Platform.isIOS: ${Platform.isIOS}');
    debugPrint('kDebugMode: $kDebugMode');
    debugPrint('Device type: ${isRealDevice ? "Real Device" : "Simulator/Test"}');
    debugPrint('Service available: $_isAvailable');
    debugPrint('=== Environment Check Complete ===');

        // 检查是否强制使用模拟支付
    if (kDebugMode && _forceUseMockPayment) {
      debugPrint('Force mock payment enabled, skipping Apple payment');
      await Future.delayed(Duration(milliseconds: 2000));
      _purchaseController.add(PurchaseResult(
        status: CustomPurchaseStatus.success,
        productId: productId,
        transactionId: 'forced_mock_${DateTime.now().millisecondsSinceEpoch}',
        message: '开发模式：强制使用模拟支付',
      ));
      return;
    }

    // 在真机上尝试苹果内购，但如果失败则提供开发模式选择
    if (isRealDevice) {
      debugPrint('Real device detected, attempting Apple In-App Purchase...');
      
      try {
        // 首先尝试从已加载的商品中查找
        iap.ProductDetails? product;
        if (_products.isNotEmpty) {
          try {
            product = _products.firstWhere((p) => p.id == productId);
          } catch (e) {
            product = null; // 商品未找到
          }
        }
        
        // 如果没有找到，尝试重新查询这个商品
        if (product == null) {
          debugPrint('❌ Product not found in loaded products, querying App Store for: $productId');
          try {
            final response = await _inAppPurchase.queryProductDetails({productId});
            debugPrint('Individual query response:');
            debugPrint('  - Found: ${response.productDetails.length}');
            debugPrint('  - Not found: ${response.notFoundIDs}');
            debugPrint('  - Error: ${response.error}');
            
            if (response.productDetails.isNotEmpty) {
              product = response.productDetails.first;
              debugPrint('✅ Found product in App Store: ${product.id} - ${product.title} - ${product.price}');
            } else {
              debugPrint('❌ Product not found in App Store: $productId');
              debugPrint('Possible reasons:');
              debugPrint('  1. Product ID mismatch between app and App Store Connect');
              debugPrint('  2. Product not approved in App Store Connect');
              debugPrint('  3. Agreements & Tax information not completed');
              debugPrint('  4. Product not available in current region');
              debugPrint('  5. Testing account not configured for sandbox');
            }
          } catch (queryError) {
            debugPrint('❌ Failed to query product from App Store: $queryError');
            debugPrint('Query error type: ${queryError.runtimeType}');
          }
        }
        
        // 如果找到了真实商品，使用苹果支付
        if (product != null) {
          debugPrint('🚀 Initiating Apple payment...');
          debugPrint('  Product ID: ${product.id}');
          debugPrint('  Product Title: ${product.title}');
          debugPrint('  Product Price: ${product.price}');
          debugPrint('  Currency: ${product.currencyCode}');
          
          final purchaseParam = iap.PurchaseParam(productDetails: product);
          
          debugPrint('📱 Calling Apple In-App Purchase API...');
          await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
          debugPrint('✅ Apple payment request sent successfully');
          debugPrint('⏳ Waiting for user interaction with Apple payment dialog...');
          debugPrint('   The payment dialog should appear now');
          return; // 等待_handlePurchaseUpdate回调
        } else {
          debugPrint('=== Product not configured in App Store Connect ===');
          debugPrint('For development testing, falling back to mock purchase');
          
          // 在开发模式下，如果商品未配置，使用模拟支付
          if (kDebugMode) {
            await Future.delayed(Duration(milliseconds: 1500));
            _purchaseController.add(PurchaseResult(
              status: CustomPurchaseStatus.success,
              productId: productId,
              transactionId: 'dev_transaction_${DateTime.now().millisecondsSinceEpoch}',
              message: '开发模式：商品未在App Store配置，使用模拟支付',
            ));
            return;
          } else {
            _purchaseController.add(PurchaseResult(
              status: CustomPurchaseStatus.failed,
              message: '商品未在App Store配置，请联系开发者',
              productId: productId,
            ));
            return;
          }
        }
      } catch (e) {
        debugPrint('Apple In-App Purchase failed: $e');
        
        // 如果是开发模式，提供模拟支付作为fallback
        if (kDebugMode) {
          debugPrint('Development fallback: Using mock purchase due to Apple payment failure');
          await Future.delayed(Duration(milliseconds: 1500));
          _purchaseController.add(PurchaseResult(
            status: CustomPurchaseStatus.success,
            productId: productId,
            transactionId: 'fallback_transaction_${DateTime.now().millisecondsSinceEpoch}',
            message: '开发模式：苹果支付失败，使用模拟支付',
          ));
          return;
        } else {
          _purchaseController.add(PurchaseResult(
            status: CustomPurchaseStatus.failed,
            message: '苹果支付失败，请确保您的Apple ID已登录且网络连接正常',
            productId: productId,
          ));
          return;
        }
      }
    }

    // 模拟器或找不到商品时的fallback
    debugPrint('Using fallback purchase (simulator or product not found)');
    
    if (kDebugMode) {
      // 模拟苹果支付的延迟
      await Future.delayed(Duration(milliseconds: 2000));
      
      _purchaseController.add(PurchaseResult(
        status: CustomPurchaseStatus.success,
        productId: productId,
        transactionId: 'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
        message: kDebugMode && !isRealDevice 
            ? '模拟器模拟购买成功' 
            : '开发模式购买成功',
      ));
    } else {
      _purchaseController.add(PurchaseResult(
        status: CustomPurchaseStatus.failed,
        message: '商品暂时不可用，请稍后重试',
        productId: productId,
      ));
    }
  }

  /// 获取商品价格（用于创建模拟商品）
  double _getProductPrice(String productId) {
    final priceMap = {
      'lelele_12': 12.0,
      'lelele_38': 38.0,
      'lelele_68': 68.0,
      'lelele_98': 98.0,
      'lelele_198': 198.0,
      'lelele_298': 298.0,
      'lelele_598': 598.0,
      'lelelevip68': 68.0,
      'lelelevip168': 168.0,
      'lelelevip399': 399.0,
    };
    return priceMap[productId] ?? 0.0;
  }

  /// 恢复购买
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _purchaseController.add(PurchaseResult(
        status: CustomPurchaseStatus.failed,
        message: '应用内购买服务不可用',
      ));
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      _purchaseController.add(PurchaseResult(
        status: CustomPurchaseStatus.failed,
        message: '恢复购买失败: $e',
      ));
    }
  }

  /// 处理购买更新
  void _handlePurchaseUpdate(List<iap.PurchaseDetails> purchaseDetailsList) {
    for (final iap.PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case iap.PurchaseStatus.pending:
          _purchaseController.add(PurchaseResult(
            status: CustomPurchaseStatus.pending,
            productId: purchaseDetails.productID,
          ));
          break;
          
        case iap.PurchaseStatus.purchased:
        case iap.PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
          
        case iap.PurchaseStatus.error:
          _purchaseController.add(PurchaseResult(
            status: CustomPurchaseStatus.failed,
            message: purchaseDetails.error?.message ?? '购买失败',
            productId: purchaseDetails.productID,
          ));
          break;
          
        case iap.PurchaseStatus.canceled:
          _purchaseController.add(PurchaseResult(
            status: CustomPurchaseStatus.cancelled,
            productId: purchaseDetails.productID,
          ));
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// 处理成功购买
  Future<void> _handleSuccessfulPurchase(iap.PurchaseDetails purchaseDetails) async {
    try {
      // 验证购买并更新用户余额
      await _verifyAndUpdatePurchase(purchaseDetails);
      
      _purchaseController.add(PurchaseResult(
        status: purchaseDetails.status == iap.PurchaseStatus.restored 
            ? CustomPurchaseStatus.restored 
            : CustomPurchaseStatus.success,
        transactionId: purchaseDetails.purchaseID,
        productId: purchaseDetails.productID,
      ));
    } catch (e) {
      debugPrint('Handle successful purchase error: $e');
      _purchaseController.add(PurchaseResult(
        status: CustomPurchaseStatus.failed,
        message: '处理购买结果失败',
        productId: purchaseDetails.productID,
      ));
    }
  }

  /// 验证购买并更新余额
  Future<void> _verifyAndUpdatePurchase(iap.PurchaseDetails purchaseDetails) async {
    // TODO: 在实际应用中，这里应该:
    // 1. 将购买凭证发送到服务器进行验证
    // 2. 服务器验证成功后更新用户余额
    // 3. 返回更新结果
    
    // 模拟服务器验证和余额更新
    await Future.delayed(Duration(seconds: 1));
    
    debugPrint('Purchase verified: ${purchaseDetails.productID}');
  }

  /// 诊断App Store Connect配置
  Future<void> diagnoseAppStoreConnectConfig() async {
    debugPrint('=== App Store Connect Configuration Diagnosis ===');
    
    // 检查基本服务可用性
    final isAvailable = await _inAppPurchase.isAvailable();
    debugPrint('In-App Purchase Service Available: $isAvailable');
    
    if (!isAvailable) {
      debugPrint('❌ In-App Purchase service is not available');
      debugPrint('Possible causes:');
      debugPrint('  - Device restrictions enabled');
      debugPrint('  - Not signed in to App Store');
      debugPrint('  - Network connectivity issues');
      return;
    }
    
    // 逐个检查商品ID
    for (String productId in _allProductIds) {
      debugPrint('\n--- Checking product: $productId ---');
      try {
        final response = await _inAppPurchase.queryProductDetails({productId});
        
        if (response.productDetails.isNotEmpty) {
          final product = response.productDetails.first;
          debugPrint('✅ Product found and configured correctly');
          debugPrint('   Title: ${product.title}');
          debugPrint('   Price: ${product.price}');
          debugPrint('   Currency: ${product.currencyCode}');
        } else {
          debugPrint('❌ Product not found');
          if (response.notFoundIDs.contains(productId)) {
            debugPrint('   Confirmed as not found in App Store');
          }
          if (response.error != null) {
            debugPrint('   Error: ${response.error}');
          }
        }
      } catch (e) {
        debugPrint('❌ Exception while checking product: $e');
      }
    }
    
    debugPrint('\n=== Diagnosis Complete ===');
    debugPrint('Next steps if products not found:');
    debugPrint('1. Verify product IDs match exactly in App Store Connect');
    debugPrint('2. Ensure products are in "Ready to Submit" or "Approved" status');
    debugPrint('3. Complete Agreements, Tax, and Banking information');
    debugPrint('4. Wait for product propagation (can take hours)');
    debugPrint('5. Test with a sandbox account');
  }

  /// 释放资源
  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}

/// iOS支付队列代理
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
} 