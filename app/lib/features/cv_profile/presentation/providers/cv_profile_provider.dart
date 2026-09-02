import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/cv_profile_repository.dart';
import '../../data/cv_tailor_remote_data_source.dart';
import '../../domain/models/cv_profile.dart';

final cvProfileRepositoryProvider = Provider<CvProfileRepository>((ref) {
  return CvProfileRepository(ref.watch(sharedPreferencesProvider));
});

final cvTailorRemoteDataSourceProvider = Provider<CvTailorRemoteDataSource>((ref) {
  return CvTailorRemoteDataSource(ref.watch(dioProvider));
});

class CvProfileNotifier extends Notifier<CvProfile> {
  @override
  CvProfile build() => ref.watch(cvProfileRepositoryProvider).load();

  void updatePersonalInfo(PersonalInfo info) {
    state = state.copyWith(personalInfo: info);
    _persist();
  }

  void upsertExperience(WorkExperience experience) {
    final index = state.experience.indexWhere((e) => e.id == experience.id);
    final updated = [...state.experience];
    if (index == -1) {
      updated.add(experience);
    } else {
      updated[index] = experience;
    }
    state = state.copyWith(experience: updated);
    _persist();
  }

  void removeExperience(String id) {
    state = state.copyWith(
      experience: state.experience.where((e) => e.id != id).toList(),
    );
    _persist();
  }

  void upsertEducation(Education education) {
    final index = state.education.indexWhere((e) => e.id == education.id);
    final updated = [...state.education];
    if (index == -1) {
      updated.add(education);
    } else {
      updated[index] = education;
    }
    state = state.copyWith(education: updated);
    _persist();
  }

  void removeEducation(String id) {
    state = state.copyWith(
      education: state.education.where((e) => e.id != id).toList(),
    );
    _persist();
  }

  void setSkills(List<String> skills) {
    state = state.copyWith(skills: skills);
    _persist();
  }

  void _persist() {
    ref.read(cvProfileRepositoryProvider).save(state);
  }
}

final cvProfileNotifierProvider = NotifierProvider<CvProfileNotifier, CvProfile>(
  CvProfileNotifier.new,
);
