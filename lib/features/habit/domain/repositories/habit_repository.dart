import '../../../../core/domain/result.dart';
import '../entities/habit.dart';
import '../entities/habit_parameter.dart';

/// Abstract contract for [Habit] and [HabitParameter] persistence.
abstract interface class IHabitRepository {
  // --- Habits ---
  Future<Result<List<Habit>>> getAllHabits();
  Future<Result<Habit>> getHabitById(String id);
  Future<Result<Habit>> getHabitByName(String name);
  Future<Result<Habit>> saveHabit(Habit habit);
  Future<Result<void>> deleteHabit(String id);

  // --- Habit Parameters ---
  Future<Result<List<HabitParameter>>> getParametersByHabitId(String habitId);
  Future<Result<HabitParameter>> getParameterById(String id);
  Future<Result<HabitParameter>> saveParameter(HabitParameter parameter);
  Future<Result<void>> deleteParameter(String id);
}
