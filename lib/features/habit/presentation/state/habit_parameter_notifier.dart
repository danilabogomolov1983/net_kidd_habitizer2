import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/habit_parameter_service.dart';
import '../../domain/entities/habit_parameter.dart';

final class HabitParameterNotifier extends Notifier<AsyncValue<List<HabitParameter>>> {
  @override
  AsyncValue<List<HabitParameter>> build() {
    load();
    return const AsyncValue.loading();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final svc = ref.read(habitParameterServiceProvider);
    final result = await svc.getAll();
    state = result.fold(
      (f) => AsyncValue.error(f, StackTrace.current),
      (list) => AsyncValue.data(list),
    );
  }

  Future<void> create({
    required String id, required String type, required String description,
    DateTime? startDate, DateTime? endDate, required double value, required String unit,
  }) async {
    final svc = ref.read(habitParameterServiceProvider);
    await svc.create(id: id, type: type, description: description,
        startDate: startDate, endDate: endDate, value: value, unit: unit);
    await load();
  }

  Future<void> update(HabitParameter p) async {
    final svc = ref.read(habitParameterServiceProvider);
    await svc.update(p);
    await load();
  }

  Future<void> delete(String id) async {
    final svc = ref.read(habitParameterServiceProvider);
    await svc.delete(id);
    await load();
  }
}

final habitParameterNotifierProvider =
    NotifierProvider<HabitParameterNotifier, AsyncValue<List<HabitParameter>>>(
        HabitParameterNotifier.new);
