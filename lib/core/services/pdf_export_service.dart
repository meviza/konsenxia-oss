import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../features/cases/domain/entities/case_entity.dart';

/// KONSENXIA — PDF Dışa Aktarma Servisi
///
/// Vaka verilerini profesyonel PDF formatına dönüştürür.
/// `pdf` ve `printing` paketlerini kullanır.
class PdfExportService {
  PdfExportService._();
  static final instance = PdfExportService._();

  /// Vaka PDF'i oluşturur ve döndürür.
  Future<pw.Document> exportCaseToPDF(CaseEntity kase) async {
    final pdf = pw.Document(
      title: '${kase.id} — ${kase.title}',
      author: 'KONSENXIA',
      creator: 'KONSENXIA PDF Export',
    );

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final now = dateFormat.format(DateTime.now());
    final createdDate = dateFormat.format(kase.createdAt);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(kase, createdDate),
        footer: (context) => _buildFooter(now, context),
        build: (context) => [
          // ── Hasta Bilgileri ────────────────────────────────
          _sectionTitle('Hasta Bilgileri'),
          pw.SizedBox(height: 6),
          _infoCard([
            _infoRow('Hasta Özeti', kase.patientSummary),
            _infoRow('Aciliyet', kase.urgency.label),
            _infoRow('Durum', kase.status.label),
            if (kase.specialties.isNotEmpty)
              _infoRow('Uzmanliklar', kase.specialties.join(', ')),
          ]),

          pw.SizedBox(height: 16),

          // ── Vital Bulgular ─────────────────────────────────
          if (kase.vitals.isNotEmpty) ...[
            _sectionTitle('Vital Bulgular'),
            pw.SizedBox(height: 6),
            _buildVitalsTable(kase.vitals),
            pw.SizedBox(height: 16),
          ],

          // ── Klinik Tablo ───────────────────────────────────
          _sectionTitle('Klinik Tablo ve Oyku'),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              kase.description,
              style: pw.TextStyle(fontSize: 10, lineSpacing: 1.6),
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Klinik Prezentasyon ─────────────────────────────
          if (kase.clinicalPresentation.isNotEmpty) ...[
            _sectionTitle('Klinik Prezentasyon'),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                kase.clinicalPresentation,
                style: pw.TextStyle(fontSize: 10, lineSpacing: 1.6),
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // ── Tani (varsa) ───────────────────────────────────
          if (kase.isSolved && kase.diagnosisTitle != null) ...[
            _sectionTitle('Tani'),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                border: pw.Border.all(color: PdfColors.green200),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    kase.diagnosisTitle!,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (kase.diagnosisDetails != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      kase.diagnosisDetails!,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // ── Tartisma Ozeti ─────────────────────────────────
          if (kase.comments.isNotEmpty) ...[
            _sectionTitle('Tartisma Ozeti (${kase.comments.length} yorum)'),
            pw.SizedBox(height: 6),
            ...kase.comments.take(10).map((c) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: c.isExpertOpinion
                          ? PdfColors.teal200
                          : c.isAcceptedAnswer
                              ? PdfColors.green200
                              : PdfColors.grey200,
                    ),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${c.authorName} — ${c.authorSpecialty}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (c.isExpertOpinion)
                            pw.Text('UZMAN',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    color: PdfColors.teal700,
                                    fontWeight: pw.FontWeight.bold)),
                          if (c.isAcceptedAnswer)
                            pw.Text('KABUL EDILEN',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    color: PdfColors.green700,
                                    fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        c.content,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                )),
            if (kase.comments.length > 10)
              pw.Text(
                '... ve ${kase.comments.length - 10} yorum daha',
                style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey500,
                    fontStyle: pw.FontStyle.italic),
              ),
          ],

          // ── Etiketler ──────────────────────────────────────
          if (kase.tags.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('Etiketler'),
            pw.SizedBox(height: 6),
            pw.Text(
              kase.tags.join(' | '),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ],
      ),
    );

    return pdf;
  }

  /// PDF'i paylas / yazdir diyalogunu acar.
  Future<void> sharePDF(CaseEntity kase) async {
    final pdf = await exportCaseToPDF(kase);
    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: '${kase.id}_konsenxia.pdf',
    );
  }

  /// PDF'i yazdir diyalogunu acar.
  Future<void> printPDF(CaseEntity kase) async {
    final pdf = await exportCaseToPDF(kase);
    final bytes = await pdf.save();

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: '${kase.id} — ${kase.title}',
    );
  }

  // ── Header ──────────────────────────────────────────────────────

  pw.Widget _buildHeader(CaseEntity kase, String createdDate) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.teal300, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'KONSENXIA',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal700,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Tibbi Vaka Raporu',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey500),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                kase.id,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Olusturma: $createdDate',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey500),
              ),
              pw.Text(
                'Yazar: ${kase.authorName} (${kase.authorSpecialty})',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────

  pw.Widget _buildFooter(String timestamp, pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'KONSENXIA — Tibbin Kolektif Zekasi',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.teal700,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Olusturulma: $timestamp  |  Sayfa ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(
                fontSize: 7, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  pw.Widget _sectionTitle(String title) {
    return pw.Row(
      children: [
        pw.Container(
          width: 3,
          height: 14,
          decoration: pw.BoxDecoration(
            color: PdfColors.teal400,
            borderRadius: pw.BorderRadius.circular(1),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _infoCard(List<pw.Widget> rows) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(children: rows),
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildVitalsTable(List<VitalSign> vitals) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Baslik
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _tableCell('Parametre', isHeader: true),
            _tableCell('Deger', isHeader: true),
            _tableCell('Birim', isHeader: true),
            _tableCell('Durum', isHeader: true),
          ],
        ),
        // Satirlar
        ...vitals.map((v) => pw.TableRow(
              children: [
                _tableCell(v.label),
                _tableCell(v.value),
                _tableCell(v.unit ?? '-'),
                _tableCell(
                  switch (v.range) {
                    VitalRange.normal => 'Normal',
                    VitalRange.warning => 'Uyari',
                    VitalRange.critical => 'Kritik',
                  },
                ),
              ],
            )),
      ],
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
