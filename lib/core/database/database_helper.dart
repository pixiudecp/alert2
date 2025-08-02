import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../app_config.dart';
import '../../models/message_model.dart';

/// 数据库助手类
/// 负责SQLite数据库的创建、升级和基本操作
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  /// 获取数据库实例
  /// 如果数据库不存在则创建新的数据库
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  /// 创建数据库文件和表结构
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConfig.databaseName);
    
    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  /// 定义消息表和设置表的结构
  Future<void> _onCreate(Database db, int version) async {
    // 创建消息表
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message_id TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 0,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        source TEXT,
        category TEXT,
        tags TEXT,
        metadata TEXT
      )
    ''');

    // 创建设置表
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('CREATE INDEX idx_messages_created_at ON messages(created_at DESC)');
    await db.execute('CREATE INDEX idx_messages_is_read ON messages(is_read)');
    await db.execute('CREATE INDEX idx_messages_type ON messages(type)');
    await db.execute('CREATE INDEX idx_messages_priority ON messages(priority DESC)');
  }

  /// 数据库升级处理
  /// 处理数据库版本升级时的表结构变更
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 根据版本号执行相应的升级脚本
    if (oldVersion < 2) {
      // 版本2的升级脚本
      // await db.execute('ALTER TABLE messages ADD COLUMN new_column TEXT');
    }
  }

  /// 插入消息
  /// 将新消息保存到数据库中
  Future<int> insertMessage(MessageModel message) async {
    final db = await database;
    return await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入消息
  /// 提高大量消息插入的性能
  Future<void> insertMessages(List<MessageModel> messages) async {
    final db = await database;
    final batch = db.batch();
    
    for (final message in messages) {
      batch.insert(
        'messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  /// 获取消息列表
  /// 支持分页、排序和筛选
  Future<List<MessageModel>> getMessages({
    int? limit,
    int? offset,
    String? type,
    bool? isRead,
    String orderBy = 'created_at DESC',
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (type != null) {
      whereClause += 'type = ?';
      whereArgs.add(type);
    }
    
    if (isRead != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'is_read = ?';
      whereArgs.add(isRead ? 1 : 0);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    
    return List.generate(maps.length, (i) => MessageModel.fromMap(maps[i]));
  }

  /// 更新消息
  /// 修改现有消息的信息
  Future<int> updateMessage(MessageModel message) async {
    final db = await database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  /// 标记消息为已读
  /// 批量更新消息的已读状态
  Future<int> markMessagesAsRead(List<int> messageIds) async {
    final db = await database;
    final placeholders = List.filled(messageIds.length, '?').join(',');
    
    return await db.rawUpdate(
      'UPDATE messages SET is_read = 1, updated_at = ? WHERE id IN ($placeholders)',
      [DateTime.now().millisecondsSinceEpoch, ...messageIds],
    );
  }

  /// 删除消息
  /// 从数据库中删除指定消息
  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 清理旧消息
  /// 删除超过指定天数的消息以节省存储空间
  Future<int> cleanOldMessages(int daysToKeep) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;
    
    return await db.delete(
      'messages',
      where: 'created_at < ?',
      whereArgs: [cutoffTime],
    );
  }

  /// 获取消息统计信息
  /// 返回总数、未读数等统计数据
  Future<Map<String, int>> getMessageStats() async {
    final db = await database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM messages');
    final unreadResult = await db.rawQuery('SELECT COUNT(*) as count FROM messages WHERE is_read = 0');
    
    return {
      'total': totalResult.first['count'] as int,
      'unread': unreadResult.first['count'] as int,
    };
  }

  /// 关闭数据库连接
  /// 释放数据库资源
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}