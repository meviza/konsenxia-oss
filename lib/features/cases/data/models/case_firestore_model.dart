import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/case_entity.dart';

/// KONSENXIA — CaseFirestoreModel
///
/// Firestore dökümanını [CaseEntity] domain objesine ve
/// domain objesini Firestore'a yazılabilir Map'e dönüştürür.
///
/// Koleksiyon: `cases/{caseId}`
/// Subcollection: `cases/{caseId}/comments/{commentId}`

class CaseFirestoreModel {
  static const String _collection = 'cases';
  static String get collection => _collection;

  // ── fromFirestore ────────────────────────────────────────────

  static CaseEntity fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    bool isLikedByCurrentUser = false,
    bool isBookmarkedByCurrentUser = false,
  }) {
    final d = doc.data()!;
    return CaseEntity(
      id:                   doc.id,
      title:                d['title'] as String? ?? '',
      description:          d['description'] as String? ?? '',
      clinicalPresentation: d['clinicalPresentation'] as String? ?? '',
      patientSummary:       d['patientSummary'] as String? ?? '',
      authorId:             d['authorId'] as String? ?? '',
      authorName:           d['authorName'] as String? ?? '',
      authorImageUrl:       d['authorImageUrl'] as String?,
      authorSpecialty:      d['authorSpecialty'] as String? ?? '',
      authorCountry:        d['authorCountry'] as String?,
      authorLevel:          (d['authorLevel'] as num?)?.toInt() ?? 1,
      urgency: _parseUrgency(d['urgency'] as String?),
      status:  _parseStatus(d['status'] as String?),
      specialties: _parseStringList(d['specialties']),
      tags:        _parseStringList(d['tags']),
      vitals:      _parseVitals(d['vitals']),
      images:      _parseImages(d['images']),
      // Comments loaded separately from subcollection
      comments: [],
      viewCount:             (d['viewCount'] as num?)?.toInt() ?? 0,
      likeCount:             (d['likeCount'] as num?)?.toInt() ?? 0,
      bookmarkCount:         (d['bookmarkCount'] as num?)?.toInt() ?? 0,
      isLikedByCurrentUser:    isLikedByCurrentUser,
      isBookmarkedByCurrentUser: isBookmarkedByCurrentUser,
      createdAt:  _parseTimestamp(d['createdAt']),
      updatedAt:  d['updatedAt'] != null ? _parseTimestamp(d['updatedAt']) : null,
      diagnosisTitle:   d['diagnosisTitle'] as String?,
      diagnosisDetails: d['diagnosisDetails'] as String?,
      xpReward: d['xpReward'] != null
          ? _parseXpReward(d['xpReward'] as Map<String, dynamic>)
          : null,
    );
  }

  // ── toFirestore ──────────────────────────────────────────────

  static Map<String, dynamic> toMap(CaseEntity c) => {
        'title':                c.title,
        'description':          c.description,
        'clinicalPresentation': c.clinicalPresentation,
        'patientSummary':       c.patientSummary,
        'authorId':             c.authorId,
        'authorName':           c.authorName,
        'authorImageUrl':       c.authorImageUrl,
        'authorSpecialty':      c.authorSpecialty,
        'authorCountry':        c.authorCountry,
        'authorLevel':          c.authorLevel,
        'urgency':              c.urgency.name,
        'status':               c.status.name,
        'specialties':          c.specialties,
        'tags':                 c.tags,
        'vitals':    c.vitals.map(_vitalToMap).toList(),
        'images':    c.images.map(_imageToMap).toList(),
        'viewCount':     c.viewCount,
        'likeCount':     c.likeCount,
        'bookmarkCount': c.bookmarkCount,
        'createdAt':  FieldValue.serverTimestamp(),
        'updatedAt':  c.updatedAt != null ? Timestamp.fromDate(c.updatedAt!) : null,
        'diagnosisTitle':   c.diagnosisTitle,
        'diagnosisDetails': c.diagnosisDetails,
        'xpReward': c.xpReward != null ? _xpRewardToMap(c.xpReward!) : null,
        // Search tokens for Firestore search (lowercase title/specialty words)
        '_searchTokens': _buildSearchTokens(c),
      };

  // ── toCreateMap — for new case submission ─────────────────────

  static Map<String, dynamic> toCreateMap({
    required String title,
    required String description,
    required String clinicalPresentation,
    required String patientSummary,
    required String authorId,
    required String authorName,
    required String authorSpecialty,
    String? authorImageUrl,
    String? authorCountry,
    int authorLevel = 1,
    CaseUrgency urgency = CaseUrgency.urgent,
    List<String> specialties = const [],
    List<String> tags = const [],
    List<VitalSign> vitals = const [],
  }) =>
      {
        'title':                title,
        'description':          description,
        'clinicalPresentation': clinicalPresentation,
        'patientSummary':       patientSummary,
        'authorId':             authorId,
        'authorName':           authorName,
        'authorImageUrl':       authorImageUrl,
        'authorSpecialty':      authorSpecialty,
        'authorCountry':        authorCountry,
        'authorLevel':          authorLevel,
        'urgency':              urgency.name,
        'status':               CaseStatus.open.name,
        'specialties':          specialties,
        'tags':                 tags,
        'vitals':               vitals.map(_vitalToMap).toList(),
        'images':               [],
        'viewCount':            0,
        'likeCount':            0,
        'bookmarkCount':        0,
        'createdAt':            FieldValue.serverTimestamp(),
        'updatedAt':            null,
        'diagnosisTitle':       null,
        'diagnosisDetails':     null,
        'xpReward': {
          'xpForAuthor': 50,
          'xpForAcceptedAnswer': 100,
          'xpForComment': 20,
          'xpForView': 5,
        },
        '_searchTokens': _buildSearchTokensRaw(title, specialties),
      };

  // ── Parsers ───────────────────────────────────────────────────

  static CaseUrgency _parseUrgency(String? v) => switch (v) {
        'routine'   => CaseUrgency.routine,
        'urgent'    => CaseUrgency.urgent,
        'critical'  => CaseUrgency.critical,
        'emergency' => CaseUrgency.emergency,
        _           => CaseUrgency.urgent,
      };

  static CaseStatus _parseStatus(String? v) => switch (v) {
        'open'         => CaseStatus.open,
        'inDiscussion' => CaseStatus.inDiscussion,
        'solved'       => CaseStatus.solved,
        'archived'     => CaseStatus.archived,
        _              => CaseStatus.open,
      };

  static DateTime _parseTimestamp(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is String)    return DateTime.tryParse(ts) ?? DateTime.now();
    return DateTime.now();
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) return v.whereType<String>().toList();
    return [];
  }

  static List<VitalSign> _parseVitals(dynamic v) {
    if (v is! List) return [];
    return v.whereType<Map>().map((m) {
      return VitalSign(
        label: m['label'] as String? ?? '',
        value: m['value'] as String? ?? '',
        unit:  m['unit'] as String?,
        range: _parseVitalRange(m['range'] as String?),
      );
    }).toList();
  }

  static VitalRange _parseVitalRange(String? v) => switch (v) {
        'warning'  => VitalRange.warning,
        'critical' => VitalRange.critical,
        _          => VitalRange.normal,
      };

  static List<CaseImage> _parseImages(dynamic v) {
    if (v is! List) return [];
    return v.whereType<Map>().map((m) {
      return CaseImage(
        id:      m['id'] as String? ?? '',
        url:     m['url'] as String? ?? '',
        caption: m['caption'] as String?,
        type:    _parseImageType(m['type'] as String?),
      );
    }).toList();
  }

  static CaseImageType _parseImageType(String? v) => switch (v) {
        'radiology'  => CaseImageType.radiology,
        'pathology'  => CaseImageType.pathology,
        'lab'        => CaseImageType.lab,
        _            => CaseImageType.clinical,
      };

  static CaseXpReward _parseXpReward(Map<String, dynamic> m) {
    return CaseXpReward(
      xpForAuthor:         (m['xpForAuthor'] as num?)?.toInt()         ?? 50,
      xpForAcceptedAnswer: (m['xpForAcceptedAnswer'] as num?)?.toInt() ?? 100,
      xpForComment:        (m['xpForComment'] as num?)?.toInt()        ?? 20,
      xpForView:           (m['xpForView'] as num?)?.toInt()           ?? 5,
    );
  }

  // ── Serializers ───────────────────────────────────────────────

  static Map<String, dynamic> _vitalToMap(VitalSign v) => {
        'label': v.label,
        'value': v.value,
        'unit':  v.unit,
        'range': v.range.name,
      };

  static Map<String, dynamic> _imageToMap(CaseImage i) => {
        'id':      i.id,
        'url':     i.url,
        'caption': i.caption,
        'type':    i.type.name,
      };

  static Map<String, dynamic> _xpRewardToMap(CaseXpReward r) => {
        'xpForAuthor':         r.xpForAuthor,
        'xpForAcceptedAnswer': r.xpForAcceptedAnswer,
        'xpForComment':        r.xpForComment,
        'xpForView':           r.xpForView,
      };

  // ── Search token builder ──────────────────────────────────────

  static List<String> _buildSearchTokens(CaseEntity c) =>
      _buildSearchTokensRaw(c.title, c.specialties);

  static List<String> _buildSearchTokensRaw(
      String title, List<String> specialties) {
    final tokens = <String>{};
    // Title n-grams (prefix search)
    final words = title.toLowerCase().split(RegExp(r'\s+'));
    for (final word in words) {
      for (int i = 1; i <= word.length; i++) {
        tokens.add(word.substring(0, i));
      }
    }
    // Specialty tokens
    for (final s in specialties) {
      tokens.add(s.toLowerCase());
    }
    return tokens.toList();
  }
}

/// Comment Firestore model
/// Subcollection: `cases/{caseId}/comments/{commentId}`
class CommentFirestoreModel {
  static const String subcollection = 'comments';

  static CaseComment fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    bool isLikedByCurrentUser = false,
  }) {
    final d = doc.data()!;
    return CaseComment(
      id:              doc.id,
      authorId:        d['authorId'] as String? ?? '',
      authorName:      d['authorName'] as String? ?? '',
      authorImageUrl:  d['authorImageUrl'] as String?,
      authorSpecialty: d['authorSpecialty'] as String? ?? '',
      authorLevel:     (d['authorLevel'] as num?)?.toInt() ?? 1,
      content:         d['content'] as String? ?? '',
      likeCount:       (d['likeCount'] as num?)?.toInt() ?? 0,
      isLikedByCurrentUser: isLikedByCurrentUser,
      isExpertOpinion: d['isExpertOpinion'] as bool? ?? false,
      isAcceptedAnswer: d['isAcceptedAnswer'] as bool? ?? false,
      replies: [],  // loaded separately if needed
      createdAt: _parseTimestamp(d['createdAt']),
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String authorId,
    required String authorName,
    required String authorSpecialty,
    String? authorImageUrl,
    int authorLevel = 1,
    required String content,
  }) =>
      {
        'authorId':        authorId,
        'authorName':      authorName,
        'authorImageUrl':  authorImageUrl,
        'authorSpecialty': authorSpecialty,
        'authorLevel':     authorLevel,
        'content':         content,
        'likeCount':       0,
        'isExpertOpinion': false,
        'isAcceptedAnswer': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

  static DateTime _parseTimestamp(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    return DateTime.now();
  }
}
