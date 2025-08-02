/// 应用程序全局配置类
/// 包含应用名称、版本、API配置等常量
class AppConfig {
  // 应用基本信息
  static const String appName = 'Finance Alert';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.finance.alert';
  
  // API配置
  static const String baseUrl = 'https://api.finance-alert.com';
  static const String apiVersion = 'v1';
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // 数据库配置
  static const String databaseName = 'finance_alert.db';
  static const int databaseVersion = 1;
  
  // 通知配置
  static const String notificationChannelId = 'finance_alerts';
  static const String notificationChannelName = '金融提醒';
  static const String notificationChannelDescription = '接收重要的金融市场消息';
  
  // 前台服务配置
  static const String foregroundServiceChannelId = 'foreground_service';
  static const String foregroundServiceChannelName = '后台保活服务';
  static const int foregroundServiceNotificationId = 1000;
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxCacheSize = 1000;
  
  // 重试配置
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // 加密配置
  static const String encryptionKey = 'finance_alert_2024_key';
  
  // 日志配置
  static const bool enableLogging = true;
  static const int maxLogFiles = 7;
}