import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/job_remote_data_source.dart';
import '../../domain/models/job.dart';

final jobRemoteDataSourceProvider = Provider<JobRemoteDataSource>((ref) {
  return JobRemoteDataSource(ref.watch(dioProvider));
});

class JobSearchState {
  const JobSearchState({
    this.query = '',
    this.location = '',
    this.jobs = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = false,
  });

  final String query;
  final String location;
  final List<Job> jobs;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  bool get hasSearched => query.isNotEmpty;

  JobSearchState copyWith({
    String? query,
    String? location,
    List<Job>? jobs,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return JobSearchState(
      query: query ?? this.query,
      location: location ?? this.location,
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class JobSearchNotifier extends Notifier<JobSearchState> {
  @override
  JobSearchState build() => const JobSearchState();

  Future<void> search(String query, String location) async {
    if (query.trim().isEmpty) return;
    state = state.copyWith(
      query: query,
      location: location,
      isLoading: true,
      error: null,
      page: 1,
    );
    try {
      final dataSource = ref.read(jobRemoteDataSourceProvider);
      final result = await dataSource.search(query: query, location: location, page: 1);
      state = state.copyWith(
        jobs: result.jobs,
        isLoading: false,
        page: result.page,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final dataSource = ref.read(jobRemoteDataSourceProvider);
      final nextPage = state.page + 1;
      final result = await dataSource.search(
        query: state.query,
        location: state.location,
        page: nextPage,
      );
      state = state.copyWith(
        jobs: [...state.jobs, ...result.jobs],
        isLoading: false,
        page: result.page,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final jobSearchNotifierProvider = NotifierProvider<JobSearchNotifier, JobSearchState>(
  JobSearchNotifier.new,
);

typedef JobDetailArgs = ({String source, String id});

final jobDetailProvider = FutureProvider.family<Job, JobDetailArgs>((ref, args) {
  final dataSource = ref.watch(jobRemoteDataSourceProvider);
  return dataSource.getDetail(source: args.source, id: args.id);
});
