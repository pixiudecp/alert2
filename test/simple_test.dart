import 'package:flutter_test/flutter_test.dart';
import 'package:alert2/providers/message_provider.dart';
import 'package:alert2/models/message_model.dart';

void main() {
  test('MessageProvider 添加消息测试', () {
    final provider = MessageProvider();
    
    // 记录初始消息数量（包含占位符消息）
    final initialCount = provider.messages.length;
    
    final message = MessageModel(
      messageId: 'test_001',
      title: '测试消息',
      content: '测试内容',
      type: MessageType.urgent,
      priority: MessagePriority.high,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      source: 'test',
    );
    
    provider.addMessage(message);
    
    // 验证消息数量增加了1
    expect(provider.messages.length, initialCount + 1);
    // 验证新消息被添加到列表顶部
    expect(provider.messages.first.title, '测试消息');
    expect(provider.messages.first.messageId, 'test_001');
  });

  test('MessageProvider 初始化测试', () {
    final provider = MessageProvider();
    
    // 验证初始化时有占位符消息
    expect(provider.messages.length, 5);
    expect(provider.messages.any((msg) => msg.title == '市场提醒'), true);
    expect(provider.messages.any((msg) => msg.title == '重要新闻'), true);
  });
}

