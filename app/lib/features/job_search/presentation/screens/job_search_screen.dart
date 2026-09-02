import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/job_search_provider.dart';
import '../widgets/job_list_tile.dart';
import 'job_swipe_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobsuche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.style_outlined),
            tooltip: 'Kartenansicht',
            onPressed: state.jobs.isEmpty
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => JobSwipeScreen(jobs: state.jobs)),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: const Text('Suchen'),
                  ),
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
                  itemCount: state.jobs.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index >= state.jobs.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final job = state.jobs[index];
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
