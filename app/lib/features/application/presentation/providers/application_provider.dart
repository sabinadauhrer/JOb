import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/application_repository.dart';
import '../../data/application_send_remote_data_source.dart';
import '../../domain/models/application.dart';

const _uuid = Uuid();

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(ref.watch(sharedPreferencesProvider));
});

final applicationSendRemoteDataSourceProvider = Provider<ApplicationSendRemoteDataSource>((ref) {
  return ApplicationSendRemoteDataSource(ref.watch(dioProvider));
});

class ApplicationsNotifier extends Notifier<List<JobApplication>> {
  @override
  List<JobApplication> build() => ref.watch(applicationRepositoryProvider).load();

  bool hasAppliedTo({required String jobSource, required String jobId}) {
    return state.any((a) => a.jobSource == jobSource && a.jobId == jobId);
  }

  void markApplied({
    required String jobSource,
    required String jobId,
    required String jobTitle,
    String? company,
  }) {
    if (hasAppliedTo(jobSource: jobSource, jobId: jobId)) return;
    state = [
      ...state,
      JobApplication(
        id: _uuid.v4(),
        jobSource: jobSource,
        jobId: jobId,
        jobTitle: jobTitle,
        company: company,
        appliedAt: DateTime.now(),
      ),
    ];
    _persist();
  }

  void updateStatus(String id, ApplicationStatus status) {
    state = [
      for (final application in state)
        if (application.id == id) application.copyWith(status: status) else application,
    ];
    _persist();
  }

  void remove(String id) {
    state = state.where((a) => a.id != id).toList();
    _persist();
  }

  void _persist() {
    ref.read(applicationRepositoryProvider).save(state);
  }
}

final applicationsNotifierProvider = NotifierProvider<ApplicationsNotifier, List<JobApplication>>(
  ApplicationsNotifier.new,
);
