class SavedJob {
  const SavedJob({
    required this.jobSource,
    required this.jobId,
    required this.title,
    this.company,
    this.location,
    required this.savedAt,
  });

  final String jobSource;
  final String jobId;
  final String title;
  final String? company;
  final String? location;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'jobSource': jobSource,
    'jobId': jobId,
    'title': title,
    'company': company,
    'location': location,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedJob.fromJson(Map<String, dynamic> json) {
    return SavedJob(
      jobSource: json['jobSource'] as String,
      jobId: json['jobId'] as String,
      title: json['title'] as String,
      company: json['company'] as String?,
      location: json['location'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}
