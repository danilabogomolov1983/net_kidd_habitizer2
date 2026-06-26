import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/core/domain/result.dart';
import 'package:net_kidd_habitizer2/features/tag/domain/entities/tag.dart';
import 'package:net_kidd_habitizer2/features/tag/domain/failures.dart';
import 'package:net_kidd_habitizer2/features/tag/domain/repositories/tag_repository.dart';
import 'package:net_kidd_habitizer2/features/tag/application/services/tag_service.dart';

final class FakeTagRepository implements ITagRepository {
  final List<Tag> _tags = [];

  @override
  Future<Result<List<Tag>>> getAll() async => Result.success(List.unmodifiable(_tags));

  @override
  Future<Result<Tag>> getById(String id) async {
    try {
      return Result.success(_tags.firstWhere((t) => t.id == id));
    } catch (_) {
      return Result.failure(TagNotFoundFailure(id));
    }
  }

  @override
  Future<Result<Tag>> getByName(String name) async {
    try {
      return Result.success(_tags.firstWhere((t) => t.name == name));
    } catch (_) {
      return Result.failure(TagNotFoundFailure(name));
    }
  }

  @override
  Future<Result<Tag>> save(Tag tag) async {
    final idx = _tags.indexWhere((t) => t.id == tag.id);
    if (idx >= 0) {
      _tags[idx] = tag;
    } else {
      _tags.add(tag);
    }
    return Result.success(tag);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _tags.removeWhere((t) => t.id == id);
    return Result.success(null);
  }

  @override
  Future<Result<List<Tag>>> getByTaskId(String taskId) async => Result.success([]);
}

void main() {
  late FakeTagRepository repository;
  late TagService service;

  setUp(() {
    repository = FakeTagRepository();
    service = TagService(repository);
  });

  group('TagService', () {
    group('createTag', () {
      test('creates a valid tag', () async {
        final result = await service.createTag(id: 't1', name: 'Work', color: '#FF5722');
        expect(result.isSuccess, true);
        expect(result.orNull!.name, 'Work');
        expect(result.orNull!.color, '#FF5722');
      });

      test('trims whitespace', () async {
        final result = await service.createTag(id: 't2', name: '  Fun  ');
        expect(result.orNull!.name, 'Fun');
      });

      test('fails with empty name', () async {
        final result = await service.createTag(id: 't3', name: '   ');
        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<TagValidationFailure>());
      });

      test('fails with name over 50 chars', () async {
        final result = await service.createTag(id: 't4', name: 'a' * 51);
        expect(result.isFailure, true);
      });

      test('fails on duplicate name', () async {
        await service.createTag(id: 't5', name: 'Important');
        final result = await service.createTag(id: 't6', name: 'Important');
        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<TagDuplicateFailure>());
      });
    });

    group('updateTag', () {
      test('updates an existing tag', () async {
        final created = await service.createTag(id: 't7', name: 'Old');
        final updated = created.orNull!.copyWith(name: 'New');
        final result = await service.updateTag(updated);
        expect(result.isSuccess, true);
        expect(result.orNull!.name, 'New');
      });
    });

    group('deleteTag', () {
      test('removes the tag', () async {
        await service.createTag(id: 't8', name: 'Temp');
        final result = await service.deleteTag('t8');
        expect(result.isSuccess, true);
        final all = await service.getAllTags();
        expect(all.orNull, isEmpty);
      });
    });
  });
}
