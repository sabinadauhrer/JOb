import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/presentation/widgets/apply_confirm_sheet.dart';
import '../../../cv_profile/domain/services/cv_job_matcher.dart';
import '../../../cv_profile/presentation/providers/cv_profile_provider.dart';
import '../../../cv_profile/presentation/widgets/match_stars.dart';
import '../../domain/models/job.dart';

const _skillMatcher = CvJobMatcher();

class JobSwipeScreen extends ConsumerStatefulWidget {
  const JobSwipeScreen({super.key, required this.jobs});

  final List<Job> jobs;

  @override
  ConsumerState<JobSwipeScreen> createState() => _JobSwipeScreenState();
}

class _JobSwipeScreenState extends ConsumerState<JobSwipeScreen> {
  late final List<Job> _queue = _sortedByMatch(widget.jobs);
  int _sentCount = 0;

  /// Shows the best CV matches first, so swiping surfaces the most relevant
  /// jobs early instead of in raw search-result order. Falls back to the
  /// original order when the profile has no skills to match against yet.
  List<Job> _sortedByMatch(List<Job> jobs) {
    final profile = ref.read(cvProfileNotifierProvider);
    if (profile.skills.isEmpty) return [...jobs];
    final scored = jobs
        .map((job) => (job, _skillMatcher.match(profile, job.description ?? '').score))
        .toList();
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => e.$1).toList();
  }

  /// Opens the apply-confirmation sheet for a right-swipe/like. Returns
  /// whether the card should leave the deck (a decision was actually made -
  /// sent or saved for later) as opposed to being cancelled back to the deck.
  Future<bool> _confirmLike(Job job) async {
    final outcome = await ApplyConfirmSheet.show(context, job: job);
    if (outcome == ApplyOutcome.sent && mounted) {
      setState(() => _sentCount++);
    }
    return outcome != null;
  }

  void _skip(Job job) {
    setState(() => _queue.removeWhere((j) => j.source == job.source && j.id == job.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/icons/icon_wobly_wordmark.png',
          height: 113,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Text(
            'Wobly',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('$_sentCount')),
          ),
        ],
      ),
      body: _queue.isEmpty
          ? _EmptyQueue(hadAny: widget.jobs.isNotEmpty)
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${_queue.length} verbleibend',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '← Wischen zum Ablehnen · Wischen zum Merken →',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Dismissible(
                      key: ValueKey('${_queue.first.source}-${_queue.first.id}'),
                      direction: DismissDirection.horizontal,
                      dismissThresholds: const {
                        DismissDirection.startToEnd: 0.25,
                        DismissDirection.endToStart: 0.25,
                      },
                      background: const _SwipeIndicator(
                        alignment: Alignment.centerLeft,
                        color: Colors.green,
                        assetPath: 'assets/icons/icon_favorite.png',
                      ),
                      secondaryBackground: const _SwipeIndicator(
                        alignment: Alignment.centerRight,
                        color: Colors.redAccent,
                        assetPath: 'assets/icons/icon_close.png',
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) return true;
                        return _confirmLike(_queue.first);
                      },
                      onDismissed: (_) => setState(() => _queue.removeAt(0)),
                      child: _JobSwipeCard(job: _queue.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: FloatingActionButton.large(
                          heroTag: 'skip',
                          backgroundColor: Colors.white,
                          onPressed: () => _skip(_queue.first),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/icons/icon_close.png',
                              width: 96,
                              height: 96,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.close, color: Colors.redAccent, size: 48),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: FloatingActionButton.large(
                          heroTag: 'like',
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            final job = _queue.first;
                            if (await _confirmLike(job)) {
                              setState(() => _queue.removeWhere(
                                (j) => j.source == job.source && j.id == job.id,
                              ));
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/icons/icon_favorite.png',
                              width: 96,
                              height: 96,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.favorite, color: Colors.green, size: 48),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _SwipeIndicator extends StatelessWidget {
  const _SwipeIndicator({required this.alignment, required this.color, required this.assetPath});

  final Alignment alignment;
  final Color color;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Image.asset(
        assetPath,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: color, size: 60),
      ),
    );
  }
}

class _JobSwipeCard extends ConsumerWidget {
  const _JobSwipeCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(cvProfileNotifierProvider);
    final skills = _skillMatcher.extractSkills(job.description);
    final matchResult = profile.skills.isEmpty
        ? null
        : _skillMatcher.match(profile, job.description ?? '');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(job.source), visualDensity: VisualDensity.compact),
                if (matchResult != null) ...[
                  const SizedBox(width: 8),
                  MatchStars(score: matchResult.score),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              [job.company, job.location].where((s) => s != null && s.isNotEmpty).join(' · '),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Gesuchte Fähigkeiten', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: skills.isEmpty
                    ? Text(
                        'Keine bekannten Fähigkeiten in der Anzeige erkannt.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final skill in skills)
                            Chip(
                              avatar: matchResult != null && matchResult.matchedSkills.contains(skill)
                                  ? Image.asset(
                                      'assets/icons/icon_check.png',
                                      width: 18,
                                      height: 18,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.check, size: 18),
                                    )
                                  : null,
                              label: Text(skill),
                              backgroundColor: matchResult != null &&
                                      matchResult.matchedSkills.contains(skill)
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : null,
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({required this.hadAny});

  final bool hadAny;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.style_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              hadAny ? 'Alle Stellen durchgesehen.' : 'Keine Stellen zum Durchsehen.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Gemerkte Stellen findest du unter "Verlauf".',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zurück zur Suche'),
            ),
          ],
        ),
      ),
    );
  }
}
