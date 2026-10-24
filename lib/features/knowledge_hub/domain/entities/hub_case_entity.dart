import 'package:equatable/equatable.dart';

/// KONSENXIA Knowledge Hub — Eğitim Vakası Entity
class HubCaseEntity extends Equatable {
  final String id;
  final String title;
  final String abstract_;     // Kısa özet (listelemede görünen)
  final String content;       // Tam içerik (Markdown destekli)
  final HubCaseCategory category;
  final String specialty;
  final HubDifficulty difficulty;

  // Yazar bilgileri
  final String authorId;
  final String authorName;
  final String authorSpecialty;
  final String? authorPhotoUrl;

  // Etkileşim
  final List<String> tags;
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final bool isPinned;
  final bool isLikedByCurrentUser;
  final bool isBookmarkedByCurrentUser;

  // Zaman
  final DateTime createdAt;
  final DateTime updatedAt;

  // Arama
  final List<String> searchTokens;

  const HubCaseEntity({
    required this.id,
    required this.title,
    required this.abstract_,
    required this.content,
    required this.category,
    required this.specialty,
    required this.difficulty,
    required this.authorId,
    required this.authorName,
    required this.authorSpecialty,
    this.authorPhotoUrl,
    required this.tags,
    required this.likeCount,
    required this.viewCount,
    required this.commentCount,
    required this.isPinned,
    required this.isLikedByCurrentUser,
    required this.isBookmarkedByCurrentUser,
    required this.createdAt,
    required this.updatedAt,
    required this.searchTokens,
  });

  HubCaseEntity copyWith({
    bool? isLikedByCurrentUser,
    bool? isBookmarkedByCurrentUser,
    int? likeCount,
    int? viewCount,
  }) {
    return HubCaseEntity(
      id: id, title: title, abstract_: abstract_, content: content,
      category: category, specialty: specialty, difficulty: difficulty,
      authorId: authorId, authorName: authorName, authorSpecialty: authorSpecialty,
      authorPhotoUrl: authorPhotoUrl, tags: tags,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      commentCount: commentCount,
      isPinned: isPinned,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isBookmarkedByCurrentUser: isBookmarkedByCurrentUser ?? this.isBookmarkedByCurrentUser,
      createdAt: createdAt, updatedAt: updatedAt, searchTokens: searchTokens,
    );
  }

  @override
  List<Object?> get props => [
    id, title, abstract_, content, category, specialty, difficulty,
    authorId, authorName, authorSpecialty, authorPhotoUrl, tags,
    likeCount, viewCount, commentCount, isPinned,
    isLikedByCurrentUser, isBookmarkedByCurrentUser,
    createdAt, updatedAt,
  ];
}

enum HubCaseCategory {
  all,
  clinicalPearl,
  rareDisease,
  diagnosticPitfall,
  caseSeries,
  guidelines;

  String get label => switch (this) {
    HubCaseCategory.all             => 'Tümü',
    HubCaseCategory.clinicalPearl   => 'Klinik İnci',
    HubCaseCategory.rareDisease     => 'Nadir Hastalık',
    HubCaseCategory.diagnosticPitfall => 'Tanı Tuzağı',
    HubCaseCategory.caseSeries      => 'Vaka Serileri',
    HubCaseCategory.guidelines      => 'Kılavuzlar',
  };

  String get value => switch (this) {
    HubCaseCategory.all             => 'all',
    HubCaseCategory.clinicalPearl   => 'clinical_pearl',
    HubCaseCategory.rareDisease     => 'rare_disease',
    HubCaseCategory.diagnosticPitfall => 'diagnostic_pitfall',
    HubCaseCategory.caseSeries      => 'case_series',
    HubCaseCategory.guidelines      => 'guidelines',
  };

  static HubCaseCategory fromValue(String v) => switch (v) {
    'clinical_pearl'      => HubCaseCategory.clinicalPearl,
    'rare_disease'        => HubCaseCategory.rareDisease,
    'diagnostic_pitfall'  => HubCaseCategory.diagnosticPitfall,
    'case_series'         => HubCaseCategory.caseSeries,
    'guidelines'          => HubCaseCategory.guidelines,
    _                     => HubCaseCategory.all,
  };
}

enum HubDifficulty {
  beginner,
  intermediate,
  advanced;

  String get label => switch (this) {
    HubDifficulty.beginner     => 'Başlangıç',
    HubDifficulty.intermediate => 'Orta',
    HubDifficulty.advanced     => 'İleri',
  };

  static HubDifficulty fromValue(String v) => switch (v) {
    'advanced'     => HubDifficulty.advanced,
    'beginner'     => HubDifficulty.beginner,
    _              => HubDifficulty.intermediate,
  };
}
