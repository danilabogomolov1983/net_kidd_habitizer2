import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/habit_parameter.dart';
import '../../domain/failures.dart';
import '../../domain/repositories/habit_parameter_repository.dart';
import '../../infrastructure/repositories/habit_parameter_repository_impl.dart';

final class HabitParameterService {
  final IHabitParameterRepository _repo;

  HabitParameterService(this._repo);

  Future<Result<HabitParameter>> create({
    required String id,
    required String type,
    required String description,
    DateTime? startDate,
    DateTime? endDate,
    required double value,
    required String unit,
  }) async {
    final descResult = _validateDescription(description);
    if (descResult.isFailure) return Result.failure(descResult.failureOrNull!);
    final typeResult = _validateType(type);
    if (typeResult.isFailure) return Result.failure(typeResult.failureOrNull!);
    final unitResult = _validateUnit(unit);
    if (unitResult.isFailure) return Result.failure(unitResult.failureOrNull!);

    final p = HabitParameter.create(
      id: id, type: type.trim(), description: description.trim(),
      startDate: startDate, endDate: endDate, value: value, unit: unit.trim(),
    );
    return _repo.save(p);
  }

  Future<Result<List<HabitParameter>>> getAll() => _repo.getAll();
  Future<Result<HabitParameter>> getById(String id) => _repo.getById(id);

  Future<Result<HabitParameter>> update(HabitParameter p) async {
    final d = _validateDescription(p.description);
    if (d.isFailure) return Result.failure(d.failureOrNull!);
    final t = _validateType(p.type);
    if (t.isFailure) return Result.failure(t.failureOrNull!);
    final u = _validateUnit(p.unit);
    if (u.isFailure) return Result.failure(u.failureOrNull!);
    return _repo.save(p);
  }

  Future<Result<void>> delete(String id) => _repo.delete(id);

  Result<String> _validateDescription(String v) {
    final t = v.trim();
    if (t.isEmpty) return Result.failure(const HabitValidationFailure(field: 'description', message: 'Required'));
    if (t.length > 30) return Result.failure(const HabitValidationFailure(field: 'description', message: 'Max 30 chars'));
    return Result.success(t);
  }

  Result<String> _validateType(String v) {
    final t = v.trim();
    if (t.isEmpty) return Result.failure(const HabitValidationFailure(field: 'type', message: 'Required'));
    if (t.length > 30) return Result.failure(const HabitValidationFailure(field: 'type', message: 'Max 30 chars'));
    return Result.success(t);
  }

  Result<String> _validateUnit(String v) {
    final t = v.trim();
    if (t.isEmpty) return Result.failure(const HabitValidationFailure(field: 'unit', message: 'Required'));
    if (t.length > 20) return Result.failure(const HabitValidationFailure(field: 'unit', message: 'Max 20 chars'));
    return Result.success(t);
  }
}

final habitParameterServiceProvider = Provider<HabitParameterService>((ref) {
  final repo = ref.read(habitParameterRepositoryProvider);
  return HabitParameterService(repo);
});
