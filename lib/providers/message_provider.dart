import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../core/database/database_helper.dart';

class MessageProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  
  MessageProvider() {
    _addPlaceholderMessages();
  }
  
  void _addPlaceholderMessages() {
    final now = DateTime.now();
    _messages = [
      MessageModel(
        messageId: 'placeholder_1',
        title: '市场提醒',
        content: '沪深300指数上涨2.5%，建议关注相关投资机会',
        type: MessageType.market,
        priority: MessagePriority.high,
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
        source: 'system',
      ),
      MessageModel(
        messageId: 'placeholder_2',
        title: '重要新闻',
        content: '央行宣布降准0.25个百分点，释放流动性约5000亿元',
        type: MessageType.news,
        priority: MessagePriority.critical,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        source: 'system',
      ),
      MessageModel(
        messageId: 'placeholder_3',
        title: '风险警报',
        content: '美股期货大幅下跌，请注意风险控制',
        type: MessageType.alert,
        priority: MessagePriority.high,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        source: 'system',
      ),
      MessageModel(
        messageId: 'placeholder_4',
        title: '系统通知',
        content: '您的投资组合今日收益率为+1.2%9999999999',
        type: MessageType.system,
        priority: MessagePriority.normal,
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        source: 'system',
      ),
      MessageModel(
        messageId: 'placeholder_5',
        title: '一般消息',
        content: '金融市场开盘提醒：今日关注重要经济数据发布',
        type: MessageType.general,
        priority: MessagePriority.low,
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        source: 'system',
      ),
    ];
  }
  
  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final dbMessages = await DatabaseHelper.instance.getMessages();
      if (dbMessages.isNotEmpty) {
        _messages = dbMessages;
      }
      // 如果数据库为空，保持占位符消息不变
    } catch (e) {
      print('加载消息失败: $e');
      // 出错时也保持占位符消息
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void addMessage(MessageModel message) {
    _messages.insert(0, message);
    notifyListeners();
  }
}


