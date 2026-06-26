import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/tag_notifier.dart';
import '../widgets/tag_chip.dart';
import '../widgets/tag_form.dart';

final class TagListPage extends ConsumerWidget {
  const TagListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagNotifierProvider);
    final notifier = ref.read(tagNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.loadTags(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tags) {
          if (tags.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No tags yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => notifier.loadTags(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TagChipWidget(tag: tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => notifier.deleteTag(tag.id),
                        tooltip: 'Delete tag',
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateForm(context, notifier),
        tooltip: 'New Tag',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateForm(BuildContext context, TagNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TagForm(
        onSubmit: (id, name, color) {
          notifier.createTag(id: id, name: name, color: color);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
