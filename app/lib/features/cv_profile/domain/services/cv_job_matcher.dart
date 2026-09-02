import '../models/cv_profile.dart';

/// A small, curated vocabulary of skills commonly mentioned in German job
/// postings. Used to surface skills a posting asks for that are missing
/// from the user's CV profile, without requiring any external service.
const commonSkillKeywords = [
  'Flutter', 'Dart', 'JavaScript', 'TypeScript', 'Python', 'Java', 'Kotlin',
  'Swift', 'React', 'Angular', 'Vue', 'Node.js', 'SQL', 'NoSQL', 'MongoDB',
  'PostgreSQL', 'MySQL', 'Docker', 'Kubernetes', 'AWS', 'Azure',
  'Google Cloud', 'Git', 'CI/CD', 'Scrum', 'Agile', 'Projektmanagement',
  'Kommunikation', 'Teamarbeit', 'Problemlösung', 'REST', 'GraphQL',
  'Microservices', 'Linux', 'DevOps', 'Machine Learning', 'Datenanalyse',
  'Excel', 'SAP', 'Buchhaltung', 'Vertrieb', 'Marketing', 'Kundenservice',
  'Führungserfahrung', 'Englisch', 'Deutsch', 'Französisch', 'Spanisch',
];

class CvMatchResult {
  const CvMatchResult({
    required this.matchedSkills,
    required this.missingSkills,
    required this.score,
  });

  final List<String> matchedSkills;
  final List<String> missingSkills;

  /// Share of the profile's own skills that the job posting mentions, 0..1.
  final double score;
}

class CvJobMatcher {
  const CvJobMatcher();

  bool _mentions(String text, String term) {
    final pattern = RegExp(r'\b' + RegExp.escape(term) + r'\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }

  CvMatchResult match(CvProfile profile, String jobDescription) {
    final matchedSkills = profile.skills
        .where((skill) => _mentions(jobDescription, skill))
        .toList();

    final existingSkillsLower = profile.skills.map((s) => s.toLowerCase()).toSet();
    final missingSkills = commonSkillKeywords
        .where(
          (keyword) =>
              !existingSkillsLower.contains(keyword.toLowerCase()) &&
              _mentions(jobDescription, keyword),
        )
        .toList();

    final score = profile.skills.isEmpty
        ? 0.0
        : (matchedSkills.length / profile.skills.length).clamp(0.0, 1.0);

    return CvMatchResult(
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      score: score,
    );
  }
}
