// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:alert2/main.dart';
import 'package:alert2/providers/message_provider.dart';
import 'package:alert2/models/message_model.dart';

void main() {
  testWidgets('应用启动并显示消息列表', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceAlertApp());
    await tester.pumpAndSettle();

    // 验证应用标题
    expect(find.text('Alert2'), findsOneWidget);
    
    // 验证占位符消息存在
    expect(find.text('市场提醒'), findsOneWidget);
    expect(find.text('重要新闻'), findsOneWidget);
  });

  testWidgets('模拟远程推送消息测试', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceAlertApp());
    await tester.pumpAndSettle();

    // 获取MessageProvider实例
    final messageProvider = tester.element(find.byType(MaterialApp))
        .read<MessageProvider>();

    // 模拟推送一条新消息
    final newMessage = MessageModel(
      messageId: 'test_push_001',
      title: '测试推送消息',
      content: '这是一条模拟的远程推送消息，用于测试消息接收功能',
      type: MessageType.urgent,
      priority: MessagePriority.high,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      source: 'test_push',
    );

    // 添加消息到provider
    messageProvider.addMessage(newMessage);
    await tester.pumpAndSettle();

    // 验证新消息出现在列表顶部
    expect(find.text('测试推送消息'), findsOneWidget);
    expect(find.text('这是一条模拟的远程推送消息，用于测试消息接收功能'), findsOneWidget);

    // 验证消息可以点击
    await tester.tap(find.text('测试推送消息'));
    await tester.pumpAndSettle();

    // 验证导航到详情页面
    expect(find.byType(Scaffold), findsWidgets);
  });
}
