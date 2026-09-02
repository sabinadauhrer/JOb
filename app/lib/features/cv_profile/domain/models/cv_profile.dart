class PersonalInfo {
  const PersonalInfo({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.summary = '',
  });

  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String summary;

  PersonalInfo copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? summary,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      summary: summary ?? this.summary,
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'address': address,
    'summary': summary,
  };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }
}

class WorkExperience {
  const WorkExperience({
    required this.id,
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  final String id;
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;

  WorkExperience copyWith({
    String? company,
    String? position,
    String? startDate,
    String? endDate,
    String? description,
  }) {
    return WorkExperience(
      id: id,
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'position': position,
    'startDate': startDate,
    'endDate': endDate,
    'description': description,
  };

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'] as String,
      company: json['company'] as String? ?? '',
      position: json['position'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class Education {
  const Education({
    required this.id,
    this.institution = '',
    this.degree = '',
    this.startDate = '',
    this.endDate = '',
  });

  final String id;
  final String institution;
  final String degree;
  final String startDate;
  final String endDate;

  Education copyWith({
    String? institution,
    String? degree,
    String? startDate,
    String? endDate,
  }) {
    return Education(
      id: id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'institution': institution,
    'degree': degree,
    'startDate': startDate,
    'endDate': endDate,
  };

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String,
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
    );
  }
}

class CvProfile {
  const CvProfile({
    this.personalInfo = const PersonalInfo(),
    this.experience = const [],
    this.education = const [],
    this.skills = const [],
  });

  final PersonalInfo personalInfo;
  final List<WorkExperience> experience;
  final List<Education> education;
  final List<String> skills;

  static const empty = CvProfile();

  CvProfile copyWith({
    PersonalInfo? personalInfo,
    List<WorkExperience>? experience,
    List<Education>? education,
    List<String>? skills,
  }) {
    return CvProfile(
      personalInfo: personalInfo ?? this.personalInfo,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toJson() => {
    'personalInfo': personalInfo.toJson(),
    'experience': experience.map((e) => e.toJson()).toList(),
    'education': education.map((e) => e.toJson()).toList(),
    'skills': skills,
  };

  factory CvProfile.fromJson(Map<String, dynamic> json) {
    return CvProfile(
      personalInfo: json['personalInfo'] != null
          ? PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>)
          : const PersonalInfo(),
      experience: (json['experience'] as List<dynamic>? ?? [])
          .map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic>? ?? [])
          .map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    );
  }
}
