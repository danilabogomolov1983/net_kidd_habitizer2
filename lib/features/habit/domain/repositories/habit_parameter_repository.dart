import '../../../../core/domain/result.dart';
import '../entities/habit_parameter.dart';

abstract interface class IHabitParameterRepository {
  Future<Result<List<HabitParameter>>> getAll();
  Future<Result<HabitParameter>> getById(String id);
  Future<Result<HabitParameter>> save(HabitParameter param);
  Future<Result<void>> delete(String id);
}
