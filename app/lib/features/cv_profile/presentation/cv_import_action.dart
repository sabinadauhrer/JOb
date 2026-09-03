import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/cv_profile_provider.dart';

/// Picks a PDF CV, sends it to the backend for extraction, and replaces the
/// local profile with the result. Shared between the CV editor (manual
/// import) and the job search screen (prompt-driven import before matching).
Future<void> importCvFromPdf(BuildContext context, WidgetRef ref) async {
  final files = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (files.isEmpty) return;

  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final bytes = await files.single.readAsBytes();
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
