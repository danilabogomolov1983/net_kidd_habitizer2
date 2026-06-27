import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/habit_service.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_parameter.dart';

final class HabitNotifier extends Notifier<AsyncValue<List<Habit>>> {
  @override
  AsyncValue<List<Habit>> build() {
    loadHabits();
    return const AsyncValue.loading();
  }

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    final service = ref.read(habitServiceProvider);
    final result = await service.getAllHabits();
    state = result.fold(
      (f) => AsyncValue.error(f, StackTrace.current),
      (habits) => AsyncValue.data(habits),
    );
  }

  Future<void> createHabit({
    required String id,
    required String type,
    required String name,
  }) async {
    final service = ref.read(habitServiceProvider);
    await service.createHabit(id: id, type: type, name: name);
    await loadHabits();
  }

  Future<void> updateHabit(Habit updated) async {
    final service = ref.read(habitServiceProvider);
    await service.updateHabit(updated);
    await loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    final service = ref.read(habitServiceProvider);
    await service.deleteHabit(id);
    await loadHabits();
  }
}

final habitNotifierProvider =
    NotifierProvider<HabitNotifier, AsyncValue<List<Habit>>>(
  HabitNotifier.new,
);

/// State notifier for parameters of a single habit.
final class HabitParameterNotifier
    extends FamilyNotifier<AsyncValue<List<HabitParameter>>, String> {
  @override
  AsyncValue<List<HabitParameter>> build(String arg) {
    loadParameters(arg);
    return const AsyncValue.loading();
  }

  Future<void> loadParameters(String habitId) async {
    state = const AsyncValue.loading();
    final service = ref.read(habitServiceProvider);
    final result = await service.getParametersByHabitId(habitId);
    state = result.fold(
      (f) => AsyncValue.error(f, StackTrace.current),
      (params) => AsyncValue.data(params),
    );
  }

  Future<void> createParameter({
    required String id,
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
    required double value,
    required String measureUnit,
  }) async {
    final service = ref.read(habitServiceProvider);
    await service.createParameter(
      id: id,
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
      value: value,
      measureUnit: measureUnit,
    );
    await loadParameters(habitId);
  }

  Future<void> updateParameter(HabitParameter updated) async {
    final service = ref.read(habitServiceProvider);
    await service.updateParameter(updated);
    await loadParameters(updated.habitId);
  }

  Future<void> deleteParameter(String habitId, String paramId) async {
    final service = ref.read(habitServiceProvider);
    await service.deleteParameter(paramId);
    await loadParameters(habitId);
  }
}

final habitParameterNotifierProvider = NotifierProvider.family<
    HabitParameterNotifier,
    AsyncValue<List<HabitParameter>>,
    String>(
  HabitParameterNotifier.new,
);
