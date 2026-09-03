import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cv_profile/domain/models/cv_profile.dart';
import '../../../cv_profile/domain/services/cv_job_matcher.dart';
import '../../../cv_profile/presentation/cv_import_action.dart';
import '../../../cv_profile/presentation/providers/cv_profile_provider.dart';
import '../../domain/models/job.dart';
import '../providers/job_search_provider.dart';
import '../widgets/job_list_tile.dart';
import 'job_swipe_screen.dart';

const _matcher = CvJobMatcher();

class JobSearchScreen extends ConsumerStatefulWidget {
  const JobSearchScreen({super.key});

  @override
  ConsumerState<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends ConsumerState<JobSearchScreen> {
  final _queryController = TextEditingController();
  final _locationController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(jobSearchNotifierProvider.notifier).loadMore();
    }
  }

  /// Best CV matches first; unchanged order when the profile has no skills.
  List<Job> _sortedByMatch(List<Job> jobs, CvProfile profile) {
    if (profile.skills.isEmpty) return jobs;
    final scored = jobs
        .map((job) => (job, _matcher.match(profile, job.description ?? '').score))
        .toList();
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => e.$1).toList();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref
        .read(jobSearchNotifierProvider.notifier)
        .search(_queryController.text, _locationController.text);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSearchNotifierProvider);
    final cvProfile = ref.watch(cvProfileNotifierProvider);
    final hasCv = cvProfile.skills.isNotEmpty || cvProfile.experience.isNotEmpty;
    final displayJobs = _sortedByMatch(state.jobs, cvProfile);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/icons/icon_wobly_wordmark.png',
          height: 113,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text('Wobly'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.style_outlined),
            tooltip: 'Kartenansicht',
            onPressed: displayJobs.isEmpty
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => JobSwipeScreen(jobs: displayJobs)),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!hasCv)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: FilledButton.tonalIcon(
                onPressed: () => importCvFromPdf(context, ref),
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Dein CV laden & analysieren'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Suchbegriff (z.B. Softwareentwickler)',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ort (optional)',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                _GlassSearchButton(
                  onPressed: state.isLoading ? null : _submit,
                ),
              ],
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading && state.jobs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!state.hasSearched) {
                  return const Center(child: Text('Gib einen Suchbegriff ein.'));
                }
                if (state.jobs.isEmpty) {
                  return const Center(child: Text('Keine Stellen gefunden.'));
                }
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: displayJobs.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index >= displayJobs.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final job = displayJobs[index];
                    return JobListTile(
                      job: job,
                      onTap: () => context.push('/jobs/${job.source}/${job.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSearchButton extends StatelessWidget {
  const _GlassSearchButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withValues(alpha: 0.35),
                    Colors.pink.shade100.withValues(alpha: 0.35),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icons/icon_search.png',
                  height: 54,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text('Suchen'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
