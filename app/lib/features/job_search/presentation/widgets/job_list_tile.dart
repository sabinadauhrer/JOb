import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cv_profile/domain/services/cv_job_matcher.dart';
import '../../../cv_profile/presentation/providers/cv_profile_provider.dart';
import '../../../cv_profile/presentation/widgets/match_stars.dart';
import '../../domain/models/job.dart';

const _matcher = CvJobMatcher();

class JobListTile extends ConsumerWidget {
  const JobListTile({super.key, required this.job, required this.onTap});

  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(cvProfileNotifierProvider);
    final score = profile.skills.isEmpty
        ? null
        : _matcher.match(profile, job.description ?? '').score;

    return ListTile(
      title: Text(job.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              [job.company, job.location].where((s) => s != null && s.isNotEmpty).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (score != null) ...[const SizedBox(width: 8), MatchStars(score: score, size: 14)],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
