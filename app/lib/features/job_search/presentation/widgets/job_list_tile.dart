import 'package:flutter/material.dart';
import '../../domain/models/job.dart';

class JobListTile extends StatelessWidget {
  const JobListTile({super.key, required this.job, required this.onTap});

  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(job.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [job.company, job.location].where((s) => s != null && s.isNotEmpty).join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
