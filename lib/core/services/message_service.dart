import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../database/database_helper.dart';
import '../../models/message_model.dart';
import 'notification_service.dart';

/// 消息服务类
/// 处理消息的接收、存储和管理
class MessageService {
  static final MessageService _instance = MessageService._internal();
  static MessageService get instance => _instance;
  
  MessageService._internal();
  
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;
  
  /// 初始化消息服务
  Future<void> initialize() async {
    // 设置前台消息处理
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // 设置消息点击处理
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }
  
  /// 处理前台消息
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // 保存消息到数据库
    await _saveMessage(message);
    
    // 显示本地通知
    await _notificationService.showNotification(
      title: message.notification?.title ?? '金融提醒',
      body: message.notification?.body ?? '您有新的金融消息',
      payload: message.data.toString(),
    );
  }
  
  /// 处理消息点击事件
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    // 保存消息到数据库
    await _saveMessage(message);
    // 可以在这里添加导航逻辑
  }
  
  /// 保存消息到数据库
  Future<void> _saveMessage(RemoteMessage message) async {
    final messageModel = MessageModel(
      messageId: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '金融提醒',
      content: message.notification?.body ?? '您有新的金融消息',
      type: MessageType.general,
      priority: MessagePriority.normal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      source: 'firebase',
      metadata: message.data,
    );
    
    await _databaseHelper.insertMessage(messageModel);
  }
}