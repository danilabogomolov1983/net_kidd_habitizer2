// Task feature — public API barrel file.
//
// External modules should import only this file.
export 'domain/entities/task.dart';
export 'domain/failures.dart';
export 'domain/repositories/task_repository.dart';
export 'application/services/task_service.dart';
export 'application/dtos/task_dto.dart';
export 'infrastructure/repositories/task_repository_impl.dart';
export 'infrastructure/data_sources/task_local_data_source.dart';
