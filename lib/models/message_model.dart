import 'dart:convert';

/// 消息数据模型
/// 定义金融消息的数据结构和序列化方法
class MessageModel {
  final int? id;
  final String messageId;
  final String title;
  final String content;
  final MessageType type;
  final MessagePriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? source;
  final String? category;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;

  const MessageModel({
    this.id,
    required this.messageId,
    required this.title,
    required this.content,
    required this.type,
    this.priority = MessagePriority.normal,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
    this.source,
    this.category,
    this.tags,
    this.metadata,
  });

  /// 从Map创建MessageModel实例
  /// 用于数据库查询结果的反序列化
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id']?.toInt(),
      messageId: map['message_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.general,
      ),
      priority: MessagePriority.values.firstWhere(
        (e) => e.index == map['priority'],
        orElse: () => MessagePriority.normal,
      ),
      isRead: map['is_read'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      source: map['source'],
      category: map['category'],
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : null,
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    );
  }

  /// 从JSON创建MessageModel实例
  /// 用于网络请求响应的反序列化
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.general,
      ),
      priority: MessagePriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => MessagePriority.normal,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      source: json['source'],
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      metadata: json['metadata'],
    );
  }

  /// 转换为Map格式
  /// 用于数据库存储的序列化
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message_id': messageId,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'priority': priority.index,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'source': source,
      'category': category,
      'tags': tags != null ? jsonEncode(tags) : null,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  /// 转换为JSON格式
  /// 用于网络请求的序列化
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'source': source,
      'category': category,
      'tags': tags,
      'metadata': metadata,
    };
  }

  /// 创建副本并修改指定字段
  /// 用于状态更新时的不可变对象操作
  MessageModel copyWith({
    int? id,
    String? messageId,
    String? title,
    String? content,
    MessageType? type,
    MessagePriority? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    String? category,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, messageId: $messageId, title: $title, type: $type, priority: $priority, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;
}

/// 消息类型枚举
/// 定义不同类型的金融消息
enum MessageType {
  general,      // 一般消息
  urgent,       // 紧急消息
  market,       // 市场消息
  news,         // 新闻消息
  alert,        // 警报消息
  system,       // 系统消息
}

/// 消息优先级枚举
/// 定义消息的重要程度
enum MessagePriority {
  low,          // 低优先级
  normal,       // 普通优先级
  high,         // 高优先级
  critical,     // 关键优先级
}

/// 消息类型扩展
/// 为消息类型添加显示名称和图标
extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.general:
        return '一般消息';
      case MessageType.urgent:
        return '紧急消息';
      case MessageType.market:
        return '市场消息';
      case MessageType.news:
        return '新闻消息';
      case MessageType.alert:
        return '警报消息';
      case MessageType.system:
        return '系统消息';
    }
  }

  String get iconName {
    switch (this) {
      case MessageType.general:
        return 'message';
      case MessageType.urgent:
        return 'warning';
      case MessageType.market:
        return 'trending_up';
      case MessageType.news:
        return 'article';
      case MessageType.alert:
        return 'notification_important';
      case MessageType.system:
        return 'settings';
    }
  }
}

/// 消息优先级扩展
/// 为消息优先级添加显示名称和颜色
extension MessagePriorityExtension on MessagePriority {
  String get displayName {
    switch (this) {
      case MessagePriority.low:
        return '低';
      case MessagePriority.normal:
        return '普通';
      case MessagePriority.high:
        return '高';
      case MessagePriority.critical:
        return '关键';
    }
  }

  String get colorName {
    switch (this) {
      case MessagePriority.low:
        return 'grey';
      case MessagePriority.normal:
        return 'blue';
      case MessagePriority.high:
        return 'orange';
      case MessagePriority.critical:
        return 'red';
    }
  }
}