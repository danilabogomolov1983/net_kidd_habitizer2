/// Public API of the `habit` slice.
///
/// Sibling slices (shell, statistics, profile) and tests should import this
/// barrel instead of reaching into private slice folders. Infrastructure
/// wiring (`infrastructure/di`) is intentionally NOT exported — it is an
/// implementation detail of the slice.
library;

export 'domain/entities/habit_parameter.dart';
export 'domain/failures.dart';
export 'domain/repositories/habit_parameter_repository.dart';
export 'application/dtos/habit_parameter_dto.dart';
export 'application/services/habit_parameter_service.dart';
export 'presentation/state/habit_parameter_notifier.dart';
export 'presentation/state/habit_search_provider.dart';
export 'presentation/state/habit_feed_filter_provider.dart';
export 'presentation/pages/habit_parameter_list_page.dart';
export 'presentation/pages/habit_parameter_detail_page.dart';
export 'presentation/widgets/habit_parameter_card.dart';
