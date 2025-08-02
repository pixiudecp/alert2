import 'dart:async';
import 'package:flutter/services.dart';
import '../app_config.dart';

/// 前台服务类
/// 用于保持应用在后台持续运行，接收推送消息
class ForegroundService {
  static final ForegroundService _instance = ForegroundService._internal();
  static ForegroundService get instance => _instance;
  
  ForegroundService._internal();
  
  static const MethodChannel _channel = MethodChannel('foreground_service');
  
  /// 初始化前台服务
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize', {
        'channelId': AppConfig.foregroundServiceChannelId,
        'channelName': AppConfig.foregroundServiceChannelName,
        'notificationId': AppConfig.foregroundServiceNotificationId,
      });
    } catch (e) {
      // 忽略平台不支持的错误
      print('前台服务初始化失败: $e');
    }
  }
  
  /// 启动前台服务
  Future<void> startService() async {
    try {
      await _channel.invokeMethod('startService');
    } catch (e) {
      print('启动前台服务失败: $e');
    }
  }
  
  /// 停止前台服务
  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
    } catch (e) {
      print('停止前台服务失败: $e');
    }
  }
}