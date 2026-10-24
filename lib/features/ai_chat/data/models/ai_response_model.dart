// KONSENXIA — AI Response Model

class AIResponseModel {
  final String text;
  final List<String> suggestions;
  final double confidence;
  final String? sessionId;

  const AIResponseModel({
    required this.text,
    this.suggestions = const [],
    this.confidence = 0.0,
    this.sessionId,
  });

  factory AIResponseModel.fromJson(Map<String, dynamic> json) {
    return AIResponseModel(
      text: json['text'] as String? ?? '',
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      sessionId: json['sessionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'suggestions': suggestions,
        'confidence': confidence,
        'sessionId': sessionId,
      };
}
