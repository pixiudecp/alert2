import 'package:flutter/material.dart';
import '../../models/message_model.dart';

class MessageDetailScreen extends StatelessWidget {
  final MessageModel message;

  const MessageDetailScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(message.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 消息类型和优先级
            Row(
              children: [
                Chip(
                  label: Text(message.type.displayName),
                  backgroundColor: _getTypeColor(message.type),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_getPriorityText(message.priority)),
                  backgroundColor: _getPriorityColor(message.priority),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 消息内容
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // 消息信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('创建时间', _formatDateTime(message.createdAt)),
                    _buildInfoRow('来源', message.source ?? '未知'),
                    if (message.category != null)
                      _buildInfoRow('分类', message.category!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getTypeColor(MessageType type) {
    switch (type) {
      case MessageType.urgent:
        return Colors.red.shade100;
      case MessageType.market:
        return Colors.blue.shade100;
      case MessageType.news:
        return Colors.green.shade100;
      case MessageType.alert:
        return Colors.orange.shade100;
      case MessageType.system:
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getPriorityColor(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.critical:
        return Colors.red.shade200;
      case MessagePriority.high:
        return Colors.orange.shade200;
      case MessagePriority.normal:
        return Colors.blue.shade200;
      case MessagePriority.low:
        return Colors.grey.shade200;
    }
  }

  String _getPriorityText(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.critical:
        return '紧急';
      case MessagePriority.high:
        return '重要';
      case MessagePriority.normal:
        return '普通';
      case MessagePriority.low:
        return '一般';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}