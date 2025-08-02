import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_provider.dart';
import '../../core/app_config.dart';
import 'message_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alert2"),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          if (messageProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (messageProvider.messages.isEmpty) {
            return const Center(
              child: Text('暂无消息'),
            );
          }
          
          return ListView.builder(
            itemCount: messageProvider.messages.length,
            itemBuilder: (context, index) {
              final message = messageProvider.messages[index];
              return ListTile(
                title: Text(message.title),
                subtitle: Text(message.content),
                trailing: Text(
                  '${message.createdAt.hour}:${message.createdAt.minute}',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageDetailScreen(message: message),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

