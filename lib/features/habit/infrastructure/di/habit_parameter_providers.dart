import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/database/database_module.dart';
import '../../application/services/habit_parameter_service.dart';
import '../../domain/repositories/habit_parameter_repository.dart';
import '../data_sources/habit_parameter_local_data_source.dart';
import '../repositories/habit_parameter_repository_impl.dart';

/// Composition root of the habit slice.
///
/// The only place where the slice's concrete implementations are wired
/// together. Application and presentation code depend on these providers
/// (or on the service / notifier they expose) — never on the concrete
/// repository or data source classes directly.
final habitParameterRepositoryProvider =
    Provider<IHabitParameterRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  final dataSource = HabitParameterLocalDataSource(dbHelper);
  return HabitParameterRepositoryImpl(dataSource);
});

/// Service provider consumed by the presentation state notifier.
final habitParameterServiceProvider = Provider<HabitParameterService>((ref) {
  final repo = ref.read(habitParameterRepositoryProvider);
  return HabitParameterService(repo);
});
