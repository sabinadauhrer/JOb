import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/presentation/providers/application_provider.dart';
import '../providers/job_search_provider.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.source, required this.id});

  final String source;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider((source: source, id: id)));
    final applications = ref.watch(applicationsNotifierProvider);
    final alreadyApplied = applications.any(
      (a) => a.jobSource == source && a.jobId == id,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Stellendetails')),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Fehler: $error')),
        data: (job) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              if (job.company != null)
                Text(job.company!, style: Theme.of(context).textTheme.titleMedium),
              if (job.location != null)
                Text(job.location!, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(
                job.description ?? 'Keine Beschreibung verfügbar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: alreadyApplied
                      ? null
                      : () {
                          ref.read(applicationsNotifierProvider.notifier).markApplied(
                            jobSource: job.source,
                            jobId: job.id,
                            jobTitle: job.title,
                            company: job.company,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Als beworben markiert.')),
                          );
                        },
                  icon: Icon(alreadyApplied ? Icons.check : Icons.send_outlined),
                  label: Text(alreadyApplied ? 'Bereits beworben' : 'Als beworben markieren'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
