import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cv_tailor_remote_data_source.dart';
import '../../domain/services/cv_job_matcher.dart';
import '../providers/cv_profile_provider.dart';

class CvMatchSheet extends ConsumerWidget {
  const CvMatchSheet({
    super.key,
    required this.jobDescription,
    this.jobTitle,
    this.company,
  });

  final String jobDescription;
  final String? jobTitle;
  final String? company;

  static Future<void> show(
    BuildContext context, {
    required String jobDescription,
    String? jobTitle,
    String? company,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CvMatchSheet(
        jobDescription: jobDescription,
        jobTitle: jobTitle,
        company: company,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(cvProfileNotifierProvider);
    final result = const CvJobMatcher().match(profile, jobDescription);
    final percent = (result.score * 100).round();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SafeArea(
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
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
                      avatar: Image.asset(
                        'assets/icons/icon_check.png',
                        width: 18,
                        height: 18,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.check, size: 18),
                      ),
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
              const SizedBox(height: 20),
            ],
            const Divider(),
            const SizedBox(height: 12),
            _TailorSection(
              jobDescription: jobDescription,
              jobTitle: jobTitle,
              company: company,
            ),
          ],
        ),
      ),
    );
  }
}

class _TailorSection extends ConsumerStatefulWidget {
  const _TailorSection({required this.jobDescription, this.jobTitle, this.company});

  final String jobDescription;
  final String? jobTitle;
  final String? company;

  @override
  ConsumerState<_TailorSection> createState() => _TailorSectionState();
}

class _TailorSectionState extends ConsumerState<_TailorSection> {
  Future<CvTailorResult>? _future;

  void _generate() {
    final profile = ref.read(cvProfileNotifierProvider);
    setState(() {
      _future = ref.read(cvTailorRemoteDataSourceProvider).tailor(
        profile: profile,
        jobDescription: widget.jobDescription,
        jobTitle: widget.jobTitle,
        company: widget.company,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KI-Anschreiben', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Lässt vom Backend ein zugeschnittenes Kurzprofil und Anschreiben für diese '
          'Stelle formulieren, basierend auf deinem CV.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _future == null ? _generate : null,
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/icons/icon_ai.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome),
              ),
            ),
            label: const Text('Anschreiben generieren'),
          ),
        ),
        if (_future != null) ...[
          const SizedBox(height: 16),
          FutureBuilder<CvTailorResult>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fehler: ${snapshot.error}',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    TextButton(onPressed: _generate, child: const Text('Erneut versuchen')),
                  ],
                );
              }
              final result = snapshot.data;
              if (result == null) return const SizedBox.shrink();
              return _TailorResultView(result: result);
            },
          ),
        ],
      ],
    );
  }
}

class _TailorResultView extends ConsumerWidget {
  const _TailorResultView({required this.result});

  final CvTailorResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vorgeschlagenes Kurzprofil', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(result.tailoredSummary),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              final profile = ref.read(cvProfileNotifierProvider);
              ref
                  .read(cvProfileNotifierProvider.notifier)
                  .updatePersonalInfo(
                    profile.personalInfo.copyWith(summary: result.tailoredSummary),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kurzprofil im CV übernommen.')),
              );
            },
            child: const Text('Ins CV übernehmen'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Anschreiben-Entwurf', style: Theme.of(context).textTheme.labelLarge),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Kopieren',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: result.coverLetter));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anschreiben kopiert.')),
                  );
                }
              },
            ),
          ],
        ),
        Text(result.coverLetter),
      ],
    );
  }
}
