import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/cv_job_matcher.dart';
import '../providers/cv_profile_provider.dart';

class CvMatchSheet extends ConsumerWidget {
  const CvMatchSheet({super.key, required this.jobDescription});

  final String jobDescription;

  static Future<void> show(BuildContext context, {required String jobDescription}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CvMatchSheet(jobDescription: jobDescription),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(cvProfileNotifierProvider);
    final result = const CvJobMatcher().match(profile, jobDescription);
    final percent = (result.score * 100).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CV-Abgleich', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              profile.skills.isEmpty
                  ? 'Füge zuerst Skills zu deinem CV hinzu, um einen Abgleich zu sehen.'
                  : '$percent % deiner Skills passen zu dieser Stelle.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: result.score, minHeight: 8),
            ),
            const SizedBox(height: 20),
            if (result.matchedSkills.isNotEmpty) ...[
              Text('Passende Skills', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final skill in result.matchedSkills)
                    Chip(
                      avatar: const Icon(Icons.check, size: 18),
                      label: Text(skill),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            if (result.missingSkills.isNotEmpty) ...[
              Text(
                'In der Anzeige erwähnt, fehlt in deinem CV',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final skill in result.missingSkills)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(skill),
                      onPressed: () => ref
                          .read(cvProfileNotifierProvider.notifier)
                          .setSkills([...profile.skills, skill]),
                    ),
                ],
              ),
            ],
            if (profile.skills.isNotEmpty &&
                result.matchedSkills.isEmpty &&
                result.missingSkills.isEmpty)
              const Text('Keine deiner Skills oder gängige Schlagwörter wurden in der Anzeige gefunden.'),
          ],
        ),
      ),
    );
  }
}
