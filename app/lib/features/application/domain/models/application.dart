enum ApplicationStatus { applied, interview, offer, rejected }

extension ApplicationStatusLabel on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Beworben';
      case ApplicationStatus.interview:
        return 'Vorstellungsgespräch';
      case ApplicationStatus.offer:
        return 'Angebot';
      case ApplicationStatus.rejected:
        return 'Absage';
    }
  }
}

class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobSource,
    required this.jobId,
    required this.jobTitle,
    this.company,
    this.status = ApplicationStatus.applied,
    required this.appliedAt,
  });

  final String id;
  final String jobSource;
  final String jobId;
  final String jobTitle;
  final String? company;
  final ApplicationStatus status;
  final DateTime appliedAt;

  JobApplication copyWith({ApplicationStatus? status}) {
    return JobApplication(
      id: id,
      jobSource: jobSource,
      jobId: jobId,
      jobTitle: jobTitle,
      company: company,
      status: status ?? this.status,
      appliedAt: appliedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'jobSource': jobSource,
    'jobId': jobId,
    'jobTitle': jobTitle,
    'company': company,
    'status': status.name,
    'appliedAt': appliedAt.toIso8601String(),
  };

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as String,
      jobSource: json['jobSource'] as String,
      jobId: json['jobId'] as String,
      jobTitle: json['jobTitle'] as String,
      company: json['company'] as String?,
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ApplicationStatus.applied,
      ),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
    );
  }
}
