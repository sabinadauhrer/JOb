import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/models/application.dart';
import '../providers/application_provider.dart';

class ApplicationHistoryScreen extends ConsumerWidget {
  const ApplicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsNotifierProvider);
    final sorted = [...applications]..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Bewerbungen')),
      body: sorted.isEmpty
          ? _EmptyState(onSearchJobs: () => context.go('/jobs'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final application = sorted[index];
                return _ApplicationTile(
                  application: application,
                  onStatusChanged: (status) => ref
                      .read(applicationsNotifierProvider.notifier)
                      .updateStatus(application.id, status),
                  onDelete: () =>
                      ref.read(applicationsNotifierProvider.notifier).remove(application.id),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSearchJobs});

  final VoidCallback onSearchJobs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_edu_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Noch keine Bewerbungen',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Markiere Stellen auf der Detailseite als "beworben", '
              'damit sie hier mit Status und Verlauf erscheinen.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSearchJobs,
              icon: const Icon(Icons.search),
              label: const Text('Jobs durchsuchen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({
    required this.application,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final JobApplication application;
  final ValueChanged<ApplicationStatus> onStatusChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.jobTitle, style: Theme.of(context).textTheme.titleMedium),
                      if (application.company != null) Text(application.company!),
                      Text(
                        'Beworben am ${dateFormat.format(application.appliedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final status in ApplicationStatus.values)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: application.status == status,
                    onSelected: (_) => onStatusChanged(status),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
