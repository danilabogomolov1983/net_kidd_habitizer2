import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/tag_service.dart';
import '../../domain/entities/tag.dart';

final class TagNotifier extends Notifier<AsyncValue<List<Tag>>> {
  @override
  AsyncValue<List<Tag>> build() {
    loadTags();
    return const AsyncValue.loading();
  }

  Future<void> loadTags() async {
    state = const AsyncValue.loading();
    final service = ref.read(tagServiceProvider);
    final result = await service.getAllTags();
    state = result.fold(
      (f) => AsyncValue.error(f, StackTrace.current),
      (tags) => AsyncValue.data(tags),
    );
  }

  Future<void> createTag({
    required String id,
    required String name,
    String color = '#2196F3',
  }) async {
    final service = ref.read(tagServiceProvider);
    await service.createTag(id: id, name: name, color: color);
    await loadTags();
  }

  Future<void> deleteTag(String id) async {
    final service = ref.read(tagServiceProvider);
    await service.deleteTag(id);
    await loadTags();
  }
}

final tagNotifierProvider = NotifierProvider<TagNotifier, AsyncValue<List<Tag>>>(
  TagNotifier.new,
);
