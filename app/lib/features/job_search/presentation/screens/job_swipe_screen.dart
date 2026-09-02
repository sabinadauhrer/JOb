import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/presentation/widgets/apply_confirm_sheet.dart';
import '../../domain/models/job.dart';

class JobSwipeScreen extends ConsumerStatefulWidget {
  const JobSwipeScreen({super.key, required this.jobs});

  final List<Job> jobs;

  @override
  ConsumerState<JobSwipeScreen> createState() => _JobSwipeScreenState();
}

class _JobSwipeScreenState extends ConsumerState<JobSwipeScreen> {
  late final List<Job> _queue = [...widget.jobs];
  int _sentCount = 0;

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
        title: const Text('Stellen entdecken'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('$_sentCount gesendet')),
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
                  const SizedBox(height: 12),
                  Expanded(
                    child: Dismissible(
                      key: ValueKey('${_queue.first.source}-${_queue.first.id}'),
                      direction: DismissDirection.horizontal,
                      background: _SwipeIndicator(
                        alignment: Alignment.centerLeft,
                        color: Colors.green,
                        icon: Icons.favorite,
                      ),
                      secondaryBackground: _SwipeIndicator(
                        alignment: Alignment.centerRight,
                        color: Colors.redAccent,
                        icon: Icons.close,
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
                      FloatingActionButton(
                        heroTag: 'skip',
                        backgroundColor: Colors.redAccent,
                        onPressed: () => _skip(_queue.first),
                        child: const Icon(Icons.close),
                      ),
                      FloatingActionButton(
                        heroTag: 'like',
                        backgroundColor: Colors.green,
                        onPressed: () async {
                          final job = _queue.first;
                          if (await _confirmLike(job)) {
                            setState(() => _queue.removeWhere(
                              (j) => j.source == job.source && j.id == job.id,
                            ));
                          }
                        },
                        child: const Icon(Icons.favorite),
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
  const _SwipeIndicator({required this.alignment, required this.color, required this.icon});

  final Alignment alignment;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: color, size: 40),
    );
  }
}

class _JobSwipeCard extends StatelessWidget {
  const _JobSwipeCard({required this.job});

  final Job job;

  String get _snippet {
    final description = job.description?.trim();
    if (description == null || description.isEmpty) return 'Keine Beschreibung verfügbar.';
    return description.length > 260 ? '${description.substring(0, 260)}…' : description;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(label: Text(job.source), visualDensity: VisualDensity.compact),
            const SizedBox(height: 12),
            Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              [job.company, job.location].where((s) => s != null && s.isNotEmpty).join(' · '),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_snippet, style: Theme.of(context).textTheme.bodyMedium),
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
