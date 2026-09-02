import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../cv_profile/data/cv_tailor_remote_data_source.dart';
import '../../../cv_profile/domain/services/cv_pdf_builder.dart';
import '../../../cv_profile/presentation/providers/cv_profile_provider.dart';
import '../../../job_search/domain/models/job.dart';
import '../../../job_search/domain/models/saved_job.dart';
import '../../../job_search/presentation/providers/saved_jobs_provider.dart';
import '../providers/application_provider.dart';

enum ApplyOutcome { sent, savedForLater }

/// Confirmation step for a swipe-right "apply" gesture: shows a tailored
/// cover letter draft (editable) and the target address before anything is
/// actually sent - nothing goes out just because a card was swiped.
class ApplyConfirmSheet extends ConsumerStatefulWidget {
  const ApplyConfirmSheet({super.key, required this.job});

  final Job job;

  static Future<ApplyOutcome?> show(BuildContext context, {required Job job}) {
    return showModalBottomSheet<ApplyOutcome>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => ApplyConfirmSheet(job: job),
    );
  }

  @override
  ConsumerState<ApplyConfirmSheet> createState() => _ApplyConfirmSheetState();
}

class _ApplyConfirmSheetState extends ConsumerState<ApplyConfirmSheet> {
  final _coverLetterController = TextEditingController();
  late Future<CvTailorResult> _tailorFuture;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _tailorFuture = _fetchDraft();
  }

  Future<CvTailorResult> _fetchDraft() async {
    final profile = ref.read(cvProfileNotifierProvider);
    final result = await ref.read(cvTailorRemoteDataSourceProvider).tailor(
      profile: profile,
      jobDescription: widget.job.description ?? '',
      jobTitle: widget.job.title,
      company: widget.job.company,
    );
    if (mounted) _coverLetterController.text = result.coverLetter;
    return result;
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = widget.job.applicationEmail;
    if (email == null) return;
    setState(() => _sending = true);
    try {
      final profile = ref.read(cvProfileNotifierProvider);
      final pdfBytes = await const CvPdfBuilder().build(profile);
      await ref.read(applicationSendRemoteDataSourceProvider).send(
        to: email,
        subject: 'Bewerbung: ${widget.job.title}',
        body: _coverLetterController.text,
        cvPdfBase64: base64Encode(pdfBytes),
      );
      ref.read(applicationsNotifierProvider.notifier).markApplied(
        jobSource: widget.job.source,
        jobId: widget.job.id,
        jobTitle: widget.job.title,
        company: widget.job.company,
      );
      if (mounted) Navigator.of(context).pop(ApplyOutcome.sent);
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Senden fehlgeschlagen: $e')),
        );
      }
    }
  }

  Future<void> _openApplicationUrl() async {
    final url = widget.job.applicationUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _saveForLater() {
    ref.read(savedJobsNotifierProvider.notifier).save(
      SavedJob(
        jobSource: widget.job.source,
        jobId: widget.job.id,
        title: widget.job.title,
        company: widget.job.company,
        location: widget.job.location,
        savedAt: DateTime.now(),
      ),
    );
    Navigator.of(context).pop(ApplyOutcome.savedForLater);
  }

  @override
  Widget build(BuildContext context) {
    final hasEmail = widget.job.applicationEmail != null;
    final hasUrl = widget.job.applicationUrl != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SafeArea(
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Text('Bewerbung senden', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(widget.job.title, style: Theme.of(context).textTheme.titleMedium),
            if (widget.job.company != null) Text(widget.job.company!),
            const SizedBox(height: 16),
            if (hasEmail)
              Text('An: ${widget.job.applicationEmail}')
            else
              Text(
                'Keine Bewerbungs-E-Mail in der Anzeige gefunden.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            Text('Anschreiben', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            FutureBuilder<CvTailorResult>(
              future: _tailorFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anschreiben konnte nicht automatisch generiert werden: '
                        '${snapshot.error}',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _tailorFuture = _fetchDraft()),
                        child: const Text('Erneut versuchen'),
                      ),
                      TextField(
                        controller: _coverLetterController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Eigenes Anschreiben eingeben…',
                        ),
                      ),
                    ],
                  );
                }
                return TextField(
                  controller: _coverLetterController,
                  maxLines: 8,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                );
              },
            ),
            const SizedBox(height: 20),
            if (hasEmail)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_sending ? 'Wird gesendet…' : 'Jetzt senden'),
                ),
              )
            else if (hasUrl)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openApplicationUrl,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Bewerbungsseite öffnen'),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _saveForLater,
                child: const Text('Für später merken'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _sending ? null : () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
