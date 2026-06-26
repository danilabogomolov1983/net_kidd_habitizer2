import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/database/database_helper.dart';
import 'package:net_kidd_habitizer2/features/task/application/dtos/task_dto.dart';
import 'package:net_kidd_habitizer2/features/tag/application/dtos/tag_dto.dart';
import 'package:net_kidd_habitizer2/features/task/infrastructure/data_sources/task_local_data_source.dart';
import 'package:net_kidd_habitizer2/features/tag/infrastructure/data_sources/tag_local_data_source.dart';
import 'package:net_kidd_habitizer2/features/task_tag/application/services/task_tag_service.dart';

void main() {
  // Initialize ffi for sqflite in unit tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper dbHelper;
  late TaskLocalDataSource taskDs;
  late TagLocalDataSource tagDs;
  late TaskTagService service;

  setUp(() async {
    // Delete any persisted database from a previous run to avoid
    // UNIQUE constraint violations across test invocations.
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final dbFile = File('$dbPath/habitizer.db');
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    dbHelper = DatabaseHelper();
    taskDs = TaskLocalDataSource(dbHelper);
    tagDs = TagLocalDataSource(dbHelper);
    service = TaskTagService(taskDs, tagDs);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('TaskTagIntegration', () {
    test('assignTag links a task and tag', () async {
      // Insert a task
      await taskDs.insert(TaskDto(
        id: 'task1', title: 'Test', status: 'todo', priority: 'medium',
        dueDate: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ));

      // Insert a tag
      await tagDs.insert(TagDto(
        id: 'tag1', name: 'Work', color: '#FF5722',
        createdAt: DateTime.now().toIso8601String(),
      ));

      // Assign
      final result = await service.assignTag('task1', 'tag1');
      expect(result.isSuccess, true);

      // Verify
      final tagIds = await service.getTagIdsForTask('task1');
      expect(tagIds.orNull, contains('tag1'));
    });

    test('assignTag fails when task does not exist', () async {
      await tagDs.insert(TagDto(
        id: 'tag99', name: 'Ghost', color: '#000000',
        createdAt: DateTime.now().toIso8601String(),
      ));

      final result = await service.assignTag('nonexistent', 'tag99');
      expect(result.isFailure, true);
    });

    test('assignTag fails when tag does not exist', () async {
      await taskDs.insert(TaskDto(
        id: 'task99', title: 'Ghost task', status: 'todo', priority: 'low',
        dueDate: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ));

      final result = await service.assignTag('task99', 'nonexistent');
      expect(result.isFailure, true);
    });

    test('removeTag unlinks a task and tag', () async {
      await taskDs.insert(TaskDto(
        id: 'task2', title: 'Removable', status: 'todo', priority: 'high',
        dueDate: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ));
      await tagDs.insert(TagDto(
        id: 'tag2', name: 'Temp', color: '#00FF00',
        createdAt: DateTime.now().toIso8601String(),
      ));

      await service.assignTag('task2', 'tag2');
      final removeResult = await service.removeTag('task2', 'tag2');
      expect(removeResult.isSuccess, true);

      final tagIds = await service.getTagIdsForTask('task2');
      expect(tagIds.orNull, isNot(contains('tag2')));
    });

    test('duplicate link is idempotent', () async {
      await taskDs.insert(TaskDto(
        id: 'task3', title: 'Idempotent', status: 'todo', priority: 'medium',
        dueDate: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ));
      await tagDs.insert(TagDto(
        id: 'tag3', name: 'Sticky', color: '#FF0000',
        createdAt: DateTime.now().toIso8601String(),
      ));

      await service.assignTag('task3', 'tag3');
      await service.assignTag('task3', 'tag3'); // should not throw

      final tagIds = await service.getTagIdsForTask('task3');
      expect(tagIds.orNull!.length, 1); // still one link
    });
  });
}
