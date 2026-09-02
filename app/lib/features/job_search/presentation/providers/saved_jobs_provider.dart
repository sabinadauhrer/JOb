import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/saved_jobs_repository.dart';
import '../../domain/models/saved_job.dart';

final savedJobsRepositoryProvider = Provider<SavedJobsRepository>((ref) {
  return SavedJobsRepository(ref.watch(sharedPreferencesProvider));
});

class SavedJobsNotifier extends Notifier<List<SavedJob>> {
  @override
  List<SavedJob> build() => ref.watch(savedJobsRepositoryProvider).load();

  bool isSaved({required String jobSource, required String jobId}) {
    return state.any((j) => j.jobSource == jobSource && j.jobId == jobId);
  }

  void save(SavedJob job) {
    if (isSaved(jobSource: job.jobSource, jobId: job.jobId)) return;
    state = [...state, job];
    _persist();
  }

  void remove({required String jobSource, required String jobId}) {
    state = state.where((j) => !(j.jobSource == jobSource && j.jobId == jobId)).toList();
    _persist();
  }

  void _persist() {
    ref.read(savedJobsRepositoryProvider).save(state);
  }
}

final savedJobsNotifierProvider = NotifierProvider<SavedJobsNotifier, List<SavedJob>>(
  SavedJobsNotifier.new,
);
