import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/cv_profile.dart';
import '../../domain/services/cv_pdf_builder.dart';
import '../providers/cv_profile_provider.dart';

const _uuid = Uuid();

Future<void> _importCv(BuildContext context, WidgetRef ref) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return;

  final bytes = result.files.single.bytes;
  if (bytes == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datei konnte nicht gelesen werden.')),
      );
    }
    return;
  }

  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final json = await ref
        .read(cvImportRemoteDataSourceProvider)
        .importFromPdfBase64(base64Encode(bytes));
    ref.read(cvProfileNotifierProvider.notifier).replaceFromImportedJson(json);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV importiert. Bitte prüfen und ggf. anpassen.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import fehlgeschlagen: $e')),
      );
    }
  }
}

class CvProfileEditorScreen extends ConsumerWidget {
  const CvProfileEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(cvProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein CV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'CV importieren (PDF)',
            onPressed: () => _importCv(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Als PDF exportieren',
            onPressed: () => Printing.layoutPdf(
              onLayout: (_) => const CvPdfBuilder().build(profile),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Persönliche Daten'),
          _PersonalInfoForm(personalInfo: profile.personalInfo),
          const SizedBox(height: 24),
          _SectionHeader(
            'Berufserfahrung',
            onAdd: () => _editExperience(context, ref, null),
          ),
          for (final experience in profile.experience)
            _ExperienceTile(
              experience: experience,
              onTap: () => _editExperience(context, ref, experience),
              onDelete: () => ref
                  .read(cvProfileNotifierProvider.notifier)
                  .removeExperience(experience.id),
            ),
          if (profile.experience.isEmpty) const _EmptyHint('Noch keine Einträge.'),
          const SizedBox(height: 24),
          _SectionHeader(
            'Ausbildung',
            onAdd: () => _editEducation(context, ref, null),
          ),
          for (final education in profile.education)
            _EducationTile(
              education: education,
              onTap: () => _editEducation(context, ref, education),
              onDelete: () =>
                  ref.read(cvProfileNotifierProvider.notifier).removeEducation(education.id),
            ),
          if (profile.education.isEmpty) const _EmptyHint('Noch keine Einträge.'),
          const SizedBox(height: 24),
          _SectionHeader('Fähigkeiten'),
          _SkillsEditor(skills: profile.skills),
        ],
      ),
    );
  }

  Future<void> _editExperience(
    BuildContext context,
    WidgetRef ref,
    WorkExperience? existing,
  ) async {
    final result = await showDialog<WorkExperience>(
      context: context,
      builder: (_) => _ExperienceDialog(existing: existing),
    );
    if (result != null) {
      ref.read(cvProfileNotifierProvider.notifier).upsertExperience(result);
    }
  }

  Future<void> _editEducation(
    BuildContext context,
    WidgetRef ref,
    Education? existing,
  ) async {
    final result = await showDialog<Education>(
      context: context,
      builder: (_) => _EducationDialog(existing: existing),
    );
    if (result != null) {
      ref.read(cvProfileNotifierProvider.notifier).upsertEducation(result);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {super.key, this.onAdd});

  final String title;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (onAdd != null)
          IconButton(icon: const Icon(Icons.add), onPressed: onAdd, tooltip: 'Hinzufügen'),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _PersonalInfoForm extends ConsumerStatefulWidget {
  const _PersonalInfoForm({super.key, required this.personalInfo});

  final PersonalInfo personalInfo;

  @override
  ConsumerState<_PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends ConsumerState<_PersonalInfoForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _summaryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.personalInfo.fullName);
    _emailController = TextEditingController(text: widget.personalInfo.email);
    _phoneController = TextEditingController(text: widget.personalInfo.phone);
    _addressController = TextEditingController(text: widget.personalInfo.address);
    _summaryController = TextEditingController(text: widget.personalInfo.summary);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _persist() {
    ref.read(cvProfileNotifierProvider.notifier).updatePersonalInfo(
      PersonalInfo(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        summary: _summaryController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Vollständiger Name'),
          onEditingComplete: _persist,
          onTapOutside: (_) => _persist(),
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'E-Mail'),
          keyboardType: TextInputType.emailAddress,
          onEditingComplete: _persist,
          onTapOutside: (_) => _persist(),
        ),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Telefon'),
          keyboardType: TextInputType.phone,
          onEditingComplete: _persist,
          onTapOutside: (_) => _persist(),
        ),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: 'Adresse'),
          onEditingComplete: _persist,
          onTapOutside: (_) => _persist(),
        ),
        TextField(
          controller: _summaryController,
          decoration: const InputDecoration(labelText: 'Kurzprofil'),
          maxLines: 3,
          onEditingComplete: _persist,
          onTapOutside: (_) => _persist(),
        ),
      ],
    );
  }
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({
    super.key,
    required this.experience,
    required this.onTap,
    required this.onDelete,
  });

  final WorkExperience experience;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(experience.position.isEmpty ? 'Unbenannte Position' : experience.position),
        subtitle: Text(
          [
            experience.company,
            [experience.startDate, experience.endDate].where((s) => s.isNotEmpty).join(' – '),
          ].where((s) => s.isNotEmpty).join(' · '),
        ),
        onTap: onTap,
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ),
    );
  }
}

class _EducationTile extends StatelessWidget {
  const _EducationTile({
    super.key,
    required this.education,
    required this.onTap,
    required this.onDelete,
  });

  final Education education;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(education.degree.isEmpty ? 'Unbenannter Abschluss' : education.degree),
        subtitle: Text(
          [
            education.institution,
            [education.startDate, education.endDate].where((s) => s.isNotEmpty).join(' – '),
          ].where((s) => s.isNotEmpty).join(' · '),
        ),
        onTap: onTap,
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ),
    );
  }
}

class _ExperienceDialog extends StatefulWidget {
  const _ExperienceDialog({super.key, this.existing});

  final WorkExperience? existing;

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  late final TextEditingController _company;
  late final TextEditingController _position;
  late final TextEditingController _startDate;
  late final TextEditingController _endDate;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _company = TextEditingController(text: existing?.company ?? '');
    _position = TextEditingController(text: existing?.position ?? '');
    _startDate = TextEditingController(text: existing?.startDate ?? '');
    _endDate = TextEditingController(text: existing?.endDate ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
  }

  @override
  void dispose() {
    _company.dispose();
    _position.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Berufserfahrung hinzufügen' : 'Berufserfahrung bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _position, decoration: const InputDecoration(labelText: 'Position')),
            TextField(controller: _company, decoration: const InputDecoration(labelText: 'Unternehmen')),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDate,
                    decoration: const InputDecoration(labelText: 'Von'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _endDate,
                    decoration: const InputDecoration(labelText: 'Bis'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Beschreibung'),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              WorkExperience(
                id: widget.existing?.id ?? _uuid.v4(),
                company: _company.text,
                position: _position.text,
                startDate: _startDate.text,
                endDate: _endDate.text,
                description: _description.text,
              ),
            );
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

class _EducationDialog extends StatefulWidget {
  const _EducationDialog({super.key, this.existing});

  final Education? existing;

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  late final TextEditingController _institution;
  late final TextEditingController _degree;
  late final TextEditingController _startDate;
  late final TextEditingController _endDate;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _institution = TextEditingController(text: existing?.institution ?? '');
    _degree = TextEditingController(text: existing?.degree ?? '');
    _startDate = TextEditingController(text: existing?.startDate ?? '');
    _endDate = TextEditingController(text: existing?.endDate ?? '');
  }

  @override
  void dispose() {
    _institution.dispose();
    _degree.dispose();
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Ausbildung hinzufügen' : 'Ausbildung bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _degree, decoration: const InputDecoration(labelText: 'Abschluss')),
            TextField(
              controller: _institution,
              decoration: const InputDecoration(labelText: 'Institution'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDate,
                    decoration: const InputDecoration(labelText: 'Von'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _endDate,
                    decoration: const InputDecoration(labelText: 'Bis'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              Education(
                id: widget.existing?.id ?? _uuid.v4(),
                institution: _institution.text,
                degree: _degree.text,
                startDate: _startDate.text,
                endDate: _endDate.text,
              ),
            );
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

class _SkillsEditor extends ConsumerStatefulWidget {
  const _SkillsEditor({super.key, required this.skills});

  final List<String> skills;

  @override
  ConsumerState<_SkillsEditor> createState() => _SkillsEditorState();
}

class _SkillsEditorState extends ConsumerState<_SkillsEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSkill() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    if (widget.skills.contains(value)) {
      _controller.clear();
      return;
    }
    ref.read(cvProfileNotifierProvider.notifier).setSkills([...widget.skills, value]);
    _controller.clear();
  }

  void _removeSkill(String skill) {
    ref
        .read(cvProfileNotifierProvider.notifier)
        .setSkills(widget.skills.where((s) => s != skill).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in widget.skills)
              Chip(label: Text(skill), onDeleted: () => _removeSkill(skill)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Fähigkeit hinzufügen'),
                onSubmitted: (_) => _addSkill(),
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: _addSkill),
          ],
        ),
      ],
    );
  }
}
