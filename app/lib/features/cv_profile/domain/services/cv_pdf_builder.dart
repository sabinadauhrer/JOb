import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../models/cv_profile.dart';

class CvPdfBuilder {
  const CvPdfBuilder();

  Future<Uint8List> build(CvProfile profile) async {
    final doc = pw.Document();
    final info = profile.personalInfo;

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            text: info.fullName.isEmpty ? 'Lebenslauf' : info.fullName,
          ),
          pw.Text(
            [
              info.email,
              info.phone,
              info.address,
            ].where((s) => s.isNotEmpty).join(' · '),
          ),
          if (info.summary.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(info.summary),
          ],
          if (profile.experience.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, text: 'Berufserfahrung'),
            for (final experience in profile.experience)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      [experience.position, experience.company]
                          .where((s) => s.isNotEmpty)
                          .join(' – '),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      [experience.startDate, experience.endDate]
                          .where((s) => s.isNotEmpty)
                          .join(' – '),
                    ),
                    if (experience.description.isNotEmpty) pw.Text(experience.description),
                  ],
                ),
              ),
          ],
          if (profile.education.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, text: 'Ausbildung'),
            for (final education in profile.education)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      [education.degree, education.institution]
                          .where((s) => s.isNotEmpty)
                          .join(' – '),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      [education.startDate, education.endDate]
                          .where((s) => s.isNotEmpty)
                          .join(' – '),
                    ),
                  ],
                ),
              ),
          ],
          if (profile.skills.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, text: 'Fähigkeiten'),
            pw.Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [for (final skill in profile.skills) pw.Text('• $skill')],
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }
}
