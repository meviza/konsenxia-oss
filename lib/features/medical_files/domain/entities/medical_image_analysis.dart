import 'package:equatable/equatable.dart';

/// AI tarafindan yapilan tibbi goruntu analiz sonucu
class MedicalImageAnalysis extends Equatable {
  final String findings;
  final String impression;
  final List<String> recommendations;
  final double confidenceScore;
  final String aiModel;
  final DateTime analyzedAt;

  const MedicalImageAnalysis({
    required this.findings,
    required this.impression,
    required this.recommendations,
    required this.confidenceScore,
    required this.aiModel,
    required this.analyzedAt,
  });

  /// Parse AI response text into structured analysis
  factory MedicalImageAnalysis.fromAIResponse({
    required String responseText,
    required String model,
  }) {
    String findings = '';
    String impression = '';
    final recommendations = <String>[];
    double confidence = 0.0;

    // Extract Findings (Bulgular)
    final findingsRegex = RegExp(
      r'\*?\*?(?:Bulgular|Key Findings|Findings)\*?\*?:?\s*([\s\S]*?)(?=\*?\*?(?:Yorumlama|Impression|Overall|Diferansiyel|Recommendations|Öneriler|\n\*\*)|$)',
      caseSensitive: false,
    );
    final findingsMatch = findingsRegex.firstMatch(responseText);
    if (findingsMatch != null) {
      findings = findingsMatch.group(1)?.trim() ?? '';
    }

    // Extract Impression (Yorumlama)
    final impressionRegex = RegExp(
      r'\*?\*?(?:Yorumlama|Impression|Overall Impression|Genel Degerlendirme)\*?\*?:?\s*([\s\S]*?)(?=\*?\*?(?:Diferansiyel|Recommendations|Öneriler|Confidence|\n\*\*)|$)',
      caseSensitive: false,
    );
    final impressionMatch = impressionRegex.firstMatch(responseText);
    if (impressionMatch != null) {
      impression = impressionMatch.group(1)?.trim() ?? '';
    }

    // Extract Recommendations (Öneriler)
    final recsRegex = RegExp(
      r'\*?\*?(?:Öneriler|Recommendations|Oneriler)\*?\*?:?\s*([\s\S]*?)(?=\*?\*?(?:Confidence|Guven|$)|\n\n⚠|$)',
      caseSensitive: false,
    );
    final recsMatch = recsRegex.firstMatch(responseText);
    if (recsMatch != null) {
      final recsText = recsMatch.group(1)?.trim() ?? '';
      final lines = recsText.split('\n');
      for (final line in lines) {
        final cleaned = line.replaceAll(RegExp(r'^[\s\-\*\d\.]+'), '').trim();
        if (cleaned.isNotEmpty) {
          recommendations.add(cleaned);
        }
      }
    }

    // Extract Confidence Score
    final confRegex = RegExp(
      r'(?:Confidence|Guven|Score)\s*[:=]?\s*(0?\.\d+|\d+%)',
      caseSensitive: false,
    );
    final confMatch = confRegex.firstMatch(responseText);
    if (confMatch != null) {
      final raw = confMatch.group(1) ?? '0';
      if (raw.contains('%')) {
        confidence = double.tryParse(raw.replaceAll('%', '')) ?? 0;
        confidence = confidence / 100.0;
      } else {
        confidence = double.tryParse(raw) ?? 0;
      }
    } else {
      // Default confidence based on content length
      confidence = responseText.length > 200 ? 0.75 : 0.5;
    }

    // Fallback: if parsing didn't capture well, use the whole response
    if (findings.isEmpty && impression.isEmpty) {
      findings = responseText;
      confidence = 0.6;
    }

    return MedicalImageAnalysis(
      findings: findings.isNotEmpty ? findings : 'Analiz tamamlandi.',
      impression: impression.isNotEmpty ? impression : 'Detayli inceleme gereklidir.',
      recommendations: recommendations.isNotEmpty
          ? recommendations
          : ['Radyoloji uzmani degerlendirmesi onerilir'],
      confidenceScore: confidence.clamp(0.0, 1.0),
      aiModel: model,
      analyzedAt: DateTime.now(),
    );
  }

  String get confidenceLabel {
    if (confidenceScore >= 0.8) return 'Yuksek';
    if (confidenceScore >= 0.5) return 'Orta';
    return 'Dusuk';
  }

  @override
  List<Object?> get props => [
        findings,
        impression,
        recommendations,
        confidenceScore,
        aiModel,
        analyzedAt,
      ];
}
