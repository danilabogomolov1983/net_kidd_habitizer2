import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/database/database_module.dart';
import '../../../../core/infrastructure/logging/logging_module.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/failures.dart';
import '../../application/dtos/tag_dto.dart';
import '../data_sources/tag_local_data_source.dart';

final class TagRepositoryImpl implements ITagRepository {
  final TagLocalDataSource _dataSource;
  final IAppLogger _logger;

  TagRepositoryImpl(this._dataSource, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  @override
  Future<Result<List<Tag>>> getAll() async {
    try {
      final dtos = await _dataSource.getAll();
      final tags = dtos.map(tagFromDto).toList();
      _logger.debug('TagRepositoryImpl.getAll', metadata: {'count': tags.length});
      return Result.success(tags);
    } catch (e, s) {
      _logger.error('Failed to load tags', errorObject: e, stackTrace: s);
      return Result.failure(TagPersistenceFailure('Failed to load tags: $e', s));
    }
  }

  @override
  Future<Result<Tag>> getById(String id) async {
    try {
      final dto = await _dataSource.getById(id);
      if (dto == null) return Result.failure(TagNotFoundFailure(id));
      return Result.success(tagFromDto(dto));
    } catch (e, s) {
      return Result.failure(TagPersistenceFailure('Failed to load tag#$id: $e', s));
    }
  }

  @override
  Future<Result<Tag>> getByName(String name) async {
    try {
      final dto = await _dataSource.getByName(name);
      if (dto == null) return Result.failure(TagNotFoundFailure(name));
      return Result.success(tagFromDto(dto));
    } catch (e, s) {
      return Result.failure(TagPersistenceFailure('Failed to load tag by name: $e', s));
    }
  }

  @override
  Future<Result<Tag>> save(Tag tag) async {
    try {
      final isNew = (await _dataSource.getById(tag.id)) == null;
      final dto = tagToDto(tag);
      final savedDto = isNew ? await _dataSource.insert(dto) : await _dataSource.update(dto);
      if (savedDto == null) return Result.failure(TagNotFoundFailure(tag.id));
      _logger.info('Tag saved', metadata: {'tagId': tag.id, 'name': tag.name, 'isNew': isNew});
      return Result.success(tagFromDto(savedDto));
    } catch (e, s) {
      _logger.error('Failed to save tag', metadata: {'tagId': tag.id}, errorObject: e, stackTrace: s);
      return Result.failure(TagPersistenceFailure('Failed to save tag: $e', s));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      _logger.info('Tag deleted', metadata: {'tagId': id});
      return Result.success(null);
    } catch (e, s) {
      _logger.error('Failed to delete tag', metadata: {'tagId': id}, errorObject: e, stackTrace: s);
      return Result.failure(TagPersistenceFailure('Failed to delete tag#$id: $e', s));
    }
  }

  @override
  Future<Result<List<Tag>>> getByTaskId(String taskId) async {
    try {
      final dtos = await _dataSource.getByTaskId(taskId);
      return Result.success(dtos.map(tagFromDto).toList());
    } catch (e, s) {
      return Result.failure(TagPersistenceFailure('Failed to load tags for task: $e', s));
    }
  }
}

final tagRepositoryProvider = Provider<ITagRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final logger = ref.read(appLoggerProvider);
  final dataSource = TagLocalDataSource(dbHelper, logger: logger);
  return TagRepositoryImpl(dataSource, logger: logger);
});

final tagLocalDataSourceProvider = Provider<TagLocalDataSource>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final logger = ref.read(appLoggerProvider);
  return TagLocalDataSource(dbHelper, logger: logger);
});
