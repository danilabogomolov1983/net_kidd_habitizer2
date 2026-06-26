import '../../../../core/domain/result.dart';
import '../entities/tag.dart';

/// Abstract contract for [Tag] persistence.
abstract interface class ITagRepository {
  Future<Result<List<Tag>>> getAll();
  Future<Result<Tag>> getById(String id);
  Future<Result<Tag>> getByName(String name);
  Future<Result<Tag>> save(Tag tag);
  Future<Result<void>> delete(String id);
  Future<Result<List<Tag>>> getByTaskId(String taskId);
}
