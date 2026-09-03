import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/delete_icon_button.dart';
import '../../../job_search/domain/models/saved_job.dart';
import '../../../job_search/presentation/providers/saved_jobs_provider.dart';
import '../../domain/models/application.dart';
import '../providers/application_provider.dart';

class ApplicationHistoryScreen extends StatelessWidget {
  const ApplicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bewerbungen'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Bewerbungen'), Tab(text: 'Gemerkt')],
          ),
        ),
        body: const TabBarView(
          children: [_ApplicationsTab(), _SavedJobsTab()],
        ),
      ),
    );
  }
}

class _ApplicationsTab extends ConsumerWidget {
  const _ApplicationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsNotifierProvider);
    final sorted = [...applications]..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

    if (sorted.isEmpty) {
      return _EmptyState(
        icon: Icons.history_edu_outlined,
        iconAsset: 'assets/icons/icon_history.png',
        title: 'Noch keine Bewerbungen',
        message: 'Markiere Stellen auf der Detailseite als "beworben", '
            'damit sie hier mit Status und Verlauf erscheinen.',
        onSearchJobs: () => context.go('/jobs'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final application = sorted[index];
        return _ApplicationTile(
          application: application,
          onStatusChanged: (status) =>
              ref.read(applicationsNotifierProvider.notifier).updateStatus(application.id, status),
          onDelete: () => ref.read(applicationsNotifierProvider.notifier).remove(application.id),
        );
      },
    );
  }
}

class _SavedJobsTab extends ConsumerWidget {
  const _SavedJobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedJobs = ref.watch(savedJobsNotifierProvider);
    final sorted = [...savedJobs]..sort((a, b) => b.savedAt.compareTo(a.savedAt));

    if (sorted.isEmpty) {
      return _EmptyState(
        icon: Icons.favorite_border,
        title: 'Noch keine gemerkten Stellen',
        message: 'In der Kartenansicht der Jobsuche nach rechts wischen (oder ❤️ tippen), '
            'um Stellen hier zu sammeln.',
        onSearchJobs: () => context.go('/jobs'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final job = sorted[index];
        return _SavedJobTile(
          job: job,
          onOpen: () => context.push('/jobs/${job.jobSource}/${job.jobId}'),
          onRemove: () => ref
              .read(savedJobsNotifierProvider.notifier)
              .remove(jobSource: job.jobSource, jobId: job.jobId),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    this.iconAsset,
    required this.title,
    required this.message,
    required this.onSearchJobs,
  });

  final IconData icon;
  final String? iconAsset;
  final String title;
  final String message;
  final VoidCallback onSearchJobs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  iconAsset!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
                ),
              )
            else
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSearchJobs,
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icons/icon_search.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.search),
                ),
              ),
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
                DeleteIconButton(onPressed: onDelete),
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

class _SavedJobTile extends StatelessWidget {
  const _SavedJobTile({required this.job, required this.onOpen, required this.onRemove});

  final SavedJob job;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(
          [job.company, job.location].where((s) => s != null && s.isNotEmpty).join(' · '),
        ),
        onTap: onOpen,
        trailing: DeleteIconButton(onPressed: onRemove),
      ),
    );
  }
}
