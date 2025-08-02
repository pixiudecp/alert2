import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/app_config.dart';
import 'core/database/database_helper.dart';
import 'core/services/notification_service.dart';
import 'core/services/message_service.dart';
import 'core/services/foreground_service.dart';
import 'providers/message_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';
import 'firebase_options.dart';

/// 应用程序入口点
/// 初始化所有必要的服务和配置
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 初始化数据库
  await DatabaseHelper.instance.database;

  // 初始化通知服务
  await NotificationService.instance.initialize();

  // 初始化前台服务
  await ForegroundService.instance.initialize();

  // 设置Firebase消息处理
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const FinanceAlertApp());
}

/// Firebase后台消息处理器
/// 处理应用在后台时接收到的推送消息
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.showNotification(
    title: message.notification?.title ?? '金融提醒',
    body: message.notification?.body ?? '您有新的金融消息',
    payload: message.data.toString(),
  );
}

/// 应用程序主类
/// 配置全局主题、路由和状态管理
class FinanceAlertApp extends StatelessWidget {
  const FinanceAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 主题状态管理
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // 设置状态管理
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // 消息状态管理
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            
            // 主题配置
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // 本地化配置
            locale: const Locale('zh', 'CN'),
            
            // 主页面
            home: const HomeScreen(),
            
            // 路由配置
            routes: {
              '/home': (context) => const HomeScreen(),
            },
            
            // 全局错误处理
            builder: (context, widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _buildErrorWidget(errorDetails);
              };
              return widget!;
            },
          );
        },
      ),
    );
  }

  /// 构建错误显示组件
  /// 为用户提供友好的错误提示界面
  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    return Material(
      child: Container(
        color: Colors.red.shade50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '应用出现异常',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请重启应用或联系客服',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
