import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/hub_case_entity.dart';

/// KONSENXIA — Firestore ↔ HubCaseEntity dönüşüm modeli
class HubCaseModel {
  static HubCaseEntity fromDoc(
    DocumentSnapshot doc, {
    bool isLiked = false,
    bool isBookmarked = false,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return HubCaseEntity(
      id: doc.id,
      title: data['title'] as String? ?? '',
      abstract_: data['abstract'] as String? ?? '',
      content: data['content'] as String? ?? '',
      category: HubCaseCategory.fromValue(data['category'] as String? ?? ''),
      specialty: data['specialty'] as String? ?? '',
      difficulty: HubDifficulty.fromValue(data['difficulty'] as String? ?? ''),
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      authorSpecialty: data['authorSpecialty'] as String? ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      isPinned: data['isPinned'] as bool? ?? false,
      isLikedByCurrentUser: isLiked,
      isBookmarkedByCurrentUser: isBookmarked,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      searchTokens: List<String>.from(data['searchTokens'] as List? ?? []),
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String title,
    required String abstract_,
    required String content,
    required HubCaseCategory category,
    required String specialty,
    required HubDifficulty difficulty,
    required List<String> tags,
    required String authorId,
    required String authorName,
    required String authorSpecialty,
    String? authorPhotoUrl,
    required List<String> searchTokens,
  }) {
    return {
      'title': title,
      'abstract': abstract_,
      'content': content,
      'category': category.value,
      'specialty': specialty,
      'difficulty': difficulty.name,
      'authorId': authorId,
      'authorName': authorName,
      'authorSpecialty': authorSpecialty,
      'authorPhotoUrl': authorPhotoUrl,
      'tags': tags,
      'likeCount': 0,
      'viewCount': 0,
      'commentCount': 0,
      'isPinned': false,
      'isApproved': false,
      'searchTokens': searchTokens,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
