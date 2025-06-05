enum ReportType {
  inappropriate, // 不当内容
  spam,         // 垃圾信息
  fake,         // 虚假信息
  harassment,   // 骚扰信息
  copyright,    // 版权问题
  other,        // 其他
}

enum ReportStatus {
  pending,    // 待处理
  reviewing,  // 审核中
  resolved,   // 已处理
  rejected,   // 已拒绝
}

class Report {
  final String id;
  final String targetId;     // 被举报内容的ID
  final String targetType;   // 被举报内容的类型（quote, post等）
  final String targetContent; // 被举报的内容
  final ReportType type;
  final String reason;       // 举报原因描述
  final String reporterId;   // 举报人ID
  final DateTime reportTime;
  final ReportStatus status;

  const Report({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.targetContent,
    required this.type,
    required this.reason,
    required this.reporterId,
    required this.reportTime,
    this.status = ReportStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetId': targetId,
      'targetType': targetType,
      'targetContent': targetContent,
      'type': type.name,
      'reason': reason,
      'reporterId': reporterId,
      'reportTime': reportTime.toIso8601String(),
      'status': status.name,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      targetId: json['targetId'],
      targetType: json['targetType'],
      targetContent: json['targetContent'],
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.other,
      ),
      reason: json['reason'],
      reporterId: json['reporterId'],
      reportTime: DateTime.parse(json['reportTime']),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
    );
  }

  Report copyWith({
    String? id,
    String? targetId,
    String? targetType,
    String? targetContent,
    ReportType? type,
    String? reason,
    String? reporterId,
    DateTime? reportTime,
    ReportStatus? status,
  }) {
    return Report(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      targetContent: targetContent ?? this.targetContent,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      reporterId: reporterId ?? this.reporterId,
      reportTime: reportTime ?? this.reportTime,
      status: status ?? this.status,
    );
  }

  // 获取举报类型的中文描述
  String get typeDescription {
    switch (type) {
      case ReportType.inappropriate:
        return '不当内容';
      case ReportType.spam:
        return '垃圾信息';
      case ReportType.fake:
        return '虚假信息';
      case ReportType.harassment:
        return '骚扰信息';
      case ReportType.copyright:
        return '版权问题';
      case ReportType.other:
        return '其他';
    }
  }

  // 获取举报状态的中文描述
  String get statusDescription {
    switch (status) {
      case ReportStatus.pending:
        return '待处理';
      case ReportStatus.reviewing:
        return '审核中';
      case ReportStatus.resolved:
        return '已处理';
      case ReportStatus.rejected:
        return '已拒绝';
    }
  }
} 