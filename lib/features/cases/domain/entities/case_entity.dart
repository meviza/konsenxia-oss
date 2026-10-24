import 'package:equatable/equatable.dart';

/// KONSENXIA — Vaka domain entity
///
/// Tüm vaka verileri burada tanımlanır. Firestore / REST backend agnostik.
class CaseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String clinicalPresentation; // Klinik tablo
  final String patientSummary;       // Anonim hasta özeti (yaş/cinsiyet/semptom)
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String authorSpecialty;
  final String? authorCountry;
  final int authorLevel;
  final CaseUrgency urgency;
  final CaseStatus status;
  final List<String> specialties;    // İlgili uzmanlık alanları
  final List<String> tags;
  final List<VitalSign> vitals;
  final List<CaseImage> images;
  final List<CaseComment> comments;
  final int viewCount;
  final int likeCount;
  final int bookmarkCount;
  final bool isLikedByCurrentUser;
  final bool isBookmarkedByCurrentUser;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? diagnosisTitle;      // Çözüme kavuşunca eklenir
  final String? diagnosisDetails;
  final CaseXpReward? xpReward;

  const CaseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.clinicalPresentation,
    required this.patientSummary,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.authorSpecialty,
    this.authorCountry,
    this.authorLevel = 1,
    required this.urgency,
    this.status = CaseStatus.open,
    this.specialties = const [],
    this.tags = const [],
    this.vitals = const [],
    this.images = const [],
    this.comments = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.isLikedByCurrentUser = false,
    this.isBookmarkedByCurrentUser = false,
    required this.createdAt,
    this.updatedAt,
    this.diagnosisTitle,
    this.diagnosisDetails,
    this.xpReward,
  });

  bool get isSolved => status == CaseStatus.solved;

  CaseEntity copyWith({
    String? title, String? description, String? clinicalPresentation,
    String? patientSummary, CaseUrgency? urgency, CaseStatus? status,
    List<String>? specialties, List<String>? tags, List<VitalSign>? vitals,
    List<CaseImage>? images, List<CaseComment>? comments,
    int? viewCount, int? likeCount, int? bookmarkCount,
    bool? isLikedByCurrentUser, bool? isBookmarkedByCurrentUser,
    DateTime? updatedAt, String? diagnosisTitle, String? diagnosisDetails,
  }) => CaseEntity(
    id: id, authorId: authorId, authorName: authorName,
    authorImageUrl: authorImageUrl, authorSpecialty: authorSpecialty,
    authorCountry: authorCountry, authorLevel: authorLevel,
    xpReward: xpReward, createdAt: createdAt,
    title: title ?? this.title,
    description: description ?? this.description,
    clinicalPresentation: clinicalPresentation ?? this.clinicalPresentation,
    patientSummary: patientSummary ?? this.patientSummary,
    urgency: urgency ?? this.urgency,
    status: status ?? this.status,
    specialties: specialties ?? this.specialties,
    tags: tags ?? this.tags,
    vitals: vitals ?? this.vitals,
    images: images ?? this.images,
    comments: comments ?? this.comments,
    viewCount: viewCount ?? this.viewCount,
    likeCount: likeCount ?? this.likeCount,
    bookmarkCount: bookmarkCount ?? this.bookmarkCount,
    isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    isBookmarkedByCurrentUser: isBookmarkedByCurrentUser ?? this.isBookmarkedByCurrentUser,
    updatedAt: updatedAt ?? this.updatedAt,
    diagnosisTitle: diagnosisTitle ?? this.diagnosisTitle,
    diagnosisDetails: diagnosisDetails ?? this.diagnosisDetails,
  );

  @override
  List<Object?> get props => [
        id, title, urgency, status, viewCount,
        likeCount, comments.length, createdAt,
      ];
}

// ── Alt entity'ler ─────────────────────────────────────────────────

enum CaseUrgency {
  routine('Rutin'),
  urgent('Acil'),
  critical('Kritik'),
  emergency('Acil Müdahale');

  final String label;
  const CaseUrgency(this.label);
}

enum CaseStatus {
  open('Açık'),
  inDiscussion('Tartışmada'),
  solved('Çözüldü'),
  archived('Arşivlendi');

  final String label;
  const CaseStatus(this.label);
}

class VitalSign extends Equatable {
  final String label;
  final String value;
  final String? unit;
  final VitalRange range;

  const VitalSign({
    required this.label,
    required this.value,
    this.unit,
    this.range = VitalRange.normal,
  });

  @override
  List<Object?> get props => [label, value, unit, range];
}

enum VitalRange { normal, warning, critical }

class CaseImage extends Equatable {
  final String id;
  final String url;
  final String? caption;
  final CaseImageType type;

  const CaseImage({
    required this.id,
    required this.url,
    this.caption,
    this.type = CaseImageType.clinical,
  });

  @override
  List<Object?> get props => [id, url, type];
}

enum CaseImageType { clinical, radiology, pathology, lab }

class CaseComment extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String authorSpecialty;
  final int authorLevel;
  final String content;
  final int likeCount;
  final bool isLikedByCurrentUser;
  final bool isExpertOpinion;      // Uzman onayli yorum
  final bool isAcceptedAnswer;     // Vaka sahibinin kabul ettigi cevap
  final List<CaseComment> replies;
  final DateTime createdAt;
  final bool isOffline;            // Cevrimdisi eklenmis yorum

  const CaseComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.authorSpecialty,
    this.authorLevel = 1,
    required this.content,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
    this.isExpertOpinion = false,
    this.isAcceptedAnswer = false,
    this.replies = const [],
    required this.createdAt,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [id, content, likeCount, createdAt, isOffline];
}

class CaseXpReward extends Equatable {
  final int xpForAuthor;
  final int xpForAcceptedAnswer;
  final int xpForComment;
  final int xpForView;

  const CaseXpReward({
    this.xpForAuthor = 50,
    this.xpForAcceptedAnswer = 100,
    this.xpForComment = 20,
    this.xpForView = 5,
  });

  @override
  List<Object?> get props => [xpForAuthor, xpForAcceptedAnswer];
}
