import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/infrastructure/logging/logging_module.dart';
import '../../../../core/infrastructure/logging/app_logger.dart';
import '../../../../core/infrastructure/logging/noop_logger.dart';
import '../../domain/entities/tag.dart';
import '../../domain/failures.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../infrastructure/repositories/tag_repository_impl.dart';

final class TagService {
  final ITagRepository _repository;
  final IAppLogger _logger;

  TagService(this._repository, {IAppLogger? logger})
      : _logger = logger ?? const NoOpLogger();

  Future<Result<Tag>> createTag({
    required String id,
    required String name,
    String color = '#2196F3',
  }) async {
    final nameResult = _validateName(name);
    if (nameResult.isFailure) {
      _logger.warning('TagService.createTag validation failed',
          metadata: {'field': 'name', 'value': name});
      return Result<Tag>.failure(nameResult.failureOrNull!);
    }

    final trimmed = name.trim();
    final existing = await _repository.getByName(trimmed);
    if (existing.isSuccess) {
      _logger.warning('TagService.createTag duplicate', metadata: {'name': trimmed});
      return Result.failure(TagDuplicateFailure(trimmed));
    }

    final tag = Tag.create(id: id, name: trimmed, color: color);
    _logger.info('TagService.createTag', metadata: {'tagId': id, 'name': trimmed});
    return _repository.save(tag);
  }

  Future<Result<List<Tag>>> getAllTags() {
    _logger.debug('TagService.getAllTags');
    return _repository.getAll();
  }

  Future<Result<Tag>> getTagById(String id) => _repository.getById(id);

  Future<Result<Tag>> updateTag(Tag updated) async {
    final nameResult = _validateName(updated.name);
    if (nameResult.isFailure) {
      _logger.warning('TagService.updateTag validation failed',
          metadata: {'tagId': updated.id, 'field': 'name'});
      return Result<Tag>.failure(nameResult.failureOrNull!);
    }
    _logger.info('TagService.updateTag', metadata: {'tagId': updated.id});
    return _repository.save(updated);
  }

  Future<Result<void>> deleteTag(String id) {
    _logger.info('TagService.deleteTag', metadata: {'tagId': id});
    return _repository.delete(id);
  }

  Future<Result<List<Tag>>> getTagsByTaskId(String taskId) {
    _logger.debug('TagService.getTagsByTaskId', metadata: {'taskId': taskId});
    return _repository.getByTaskId(taskId);
  }

  Result<String> _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Result<String>.failure(
        const TagValidationFailure(field: 'name', message: 'Tag name must not be empty'),
      );
    }
    if (trimmed.length > 50) {
      return Result<String>.failure(
        const TagValidationFailure(field: 'name', message: 'Tag name must be 50 characters or fewer'),
      );
    }
    return Result.success(trimmed);
  }
}

final tagServiceProvider = Provider<TagService>((ref) {
  final repository = ref.read(tagRepositoryProvider);
  final logger = ref.read(appLoggerProvider);
  return TagService(repository, logger: logger);
});
