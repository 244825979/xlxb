/// 充值选项数据模型
class RechargeItem {
  final String productId;
  final String title;
  final double price;
  final int coins;
  final String priceText;
  final bool isPopular;
  final int? bonusCoins;

  const RechargeItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.coins,
    required this.priceText,
    this.isPopular = false,
    this.bonusCoins,
  });
}

/// VIP套餐数据模型
class VipPackage {
  final String productId;
  final String title;
  final double price;
  final String duration;
  final String priceText;
  final bool isPopular;
  final List<String> benefits;

  const VipPackage({
    required this.productId,
    required this.title,
    required this.price,
    required this.duration,
    required this.priceText,
    this.isPopular = false,
    required this.benefits,
  });
}

/// 自定义购买状态枚举
enum CustomPurchaseStatus {
  none,
  pending,
  success,
  failed,
  cancelled,
  restored,
}

/// 购买结果模型
class PurchaseResult {
  final CustomPurchaseStatus status;
  final String? message;
  final String? transactionId;
  final String? productId;

  const PurchaseResult({
    required this.status,
    this.message,
    this.transactionId,
    this.productId,
  });
} 