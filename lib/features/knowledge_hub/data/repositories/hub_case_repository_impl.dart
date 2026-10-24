import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/in_memory_cache.dart';
import '../../../../core/utils/hub_seed_data.dart';
import '../../../../core/utils/search_token_builder.dart';
import '../../domain/entities/hub_case_entity.dart';
import '../../domain/repositories/hub_case_repository.dart';
import '../models/hub_case_model.dart';

/// KONSENXIA — Knowledge Hub Firestore Repository Implementasyonu
class HubCaseRepositoryImpl implements HubCaseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final InMemoryCache<List<HubCaseEntity>> _listCache;
  final InMemoryCache<HubCaseEntity> _detailCache;

  HubCaseRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _listCache = InMemoryCache(ttl: const Duration(minutes: 5)),
        _detailCache = InMemoryCache(ttl: const Duration(minutes: 10));

  CollectionReference get _col => _firestore.collection('hub_cases');
  String? get _uid => _auth.currentUser?.uid;

  /// Firestore sorgusu icin maksimum bekleme suresi
  static const _queryTimeout = Duration(seconds: 5);

  // ── Listeleme ──────────────────────────────────────────────────────────
  @override
  Future<List<HubCaseEntity>> getHubCases({
    HubCaseCategory? category,
    String? specialty,
    String? lastDocId,
    int limit = 20,
  }) async {
    final cacheKey = '${category?.value ?? 'all'}_${specialty ?? ''}_${lastDocId ?? '0'}';
    final cached = _listCache.get(cacheKey);
    if (cached != null) return cached;

    try {
      Query query = _col.orderBy('isPinned', descending: true).orderBy('createdAt', descending: true);

      if (category != null && category != HubCaseCategory.all) {
        query = query.where('category', isEqualTo: category.value);
      }
      if (specialty != null && specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }
      if (lastDocId != null) {
        final lastDoc = await _col.doc(lastDocId).get().timeout(_queryTimeout);
        if (lastDoc.exists) query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);
      final snapshot = await query.get().timeout(_queryTimeout);

      final uid = _uid;
      final cases = await Future.wait(snapshot.docs.map((doc) async {
        final isLiked = uid != null ? await _isLiked(doc.id, uid) : false;
        final isBookmarked = uid != null ? await _isBookmarked(doc.id, uid) : false;
        return HubCaseModel.fromDoc(doc, isLiked: isLiked, isBookmarked: isBookmarked);
      })).timeout(_queryTimeout);

      _listCache.set(cacheKey, cases);
      return cases;
    } catch (e) {
      debugPrint('[HubCaseRepo] Firestore basarisiz, seed data kullaniliyor: $e');
      // Firestore erisilemez veya timeout — seed data fallback
      final fallback = _buildFallbackCases(category: category, limit: limit);
      _listCache.set(cacheKey, fallback);
      return fallback;
    }
  }

  /// Firestore erisilemezken seed data'dan HubCaseEntity listesi olusturur.
  List<HubCaseEntity> _buildFallbackCases({
    HubCaseCategory? category,
    int limit = 20,
  }) {
    final now = DateTime.now();
    var seeds = kHubSeedCases;

    // Kategori filtresi
    if (category != null && category != HubCaseCategory.all) {
      seeds = seeds
          .where((s) => s['category'] == category.value)
          .toList();
    }

    // Limit
    if (seeds.length > limit) {
      seeds = seeds.sublist(0, limit);
    }

    return seeds.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      return HubCaseEntity(
        id: s['id'] as String? ?? 'seed_$i',
        title: s['title'] as String? ?? '',
        abstract_: s['abstract'] as String? ?? '',
        content: s['content'] as String? ?? '',
        category: HubCaseCategory.fromValue(s['category'] as String? ?? 'all'),
        specialty: s['specialty'] as String? ?? '',
        difficulty: HubDifficulty.fromValue(s['difficulty'] as String? ?? 'intermediate'),
        authorId: s['authorId'] as String? ?? 'seed_author',
        authorName: s['authorName'] as String? ?? 'Konsenxia Editör',
        authorSpecialty: s['authorSpecialty'] as String? ?? '',
        authorPhotoUrl: null,
        tags: (s['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        likeCount: s['likeCount'] as int? ?? 0,
        viewCount: s['viewCount'] as int? ?? 0,
        commentCount: s['commentCount'] as int? ?? 0,
        isPinned: s['isPinned'] as bool? ?? false,
        isLikedByCurrentUser: false,
        isBookmarkedByCurrentUser: false,
        createdAt: now.subtract(Duration(hours: i * 6)),
        updatedAt: now.subtract(Duration(hours: i * 6)),
        searchTokens: (s['searchTokens'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    }).toList();
  }

  /// Seed data'dan ID ile tek vaka bul
  HubCaseEntity? _findSeedCaseById(String id) {
    final all = _buildFallbackCases();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Arama ──────────────────────────────────────────────────────────────
  @override
  Future<List<HubCaseEntity>> searchHubCases(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final q = query.toLowerCase().trim();
      final snapshot = await _col
          .where('searchTokens', arrayContains: q)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get()
          .timeout(_queryTimeout);

      final uid = _uid;
      return await Future.wait(snapshot.docs.map((doc) async {
        final isLiked = uid != null ? await _isLiked(doc.id, uid) : false;
        final isBookmarked = uid != null ? await _isBookmarked(doc.id, uid) : false;
        return HubCaseModel.fromDoc(doc, isLiked: isLiked, isBookmarked: isBookmarked);
      })).timeout(_queryTimeout);
    } catch (e) {
      // Firestore erisilemezken seed data icerisinde arama yap
      debugPrint('[HubCaseRepo] Arama basarisiz, seed data filtresi: $e');
      final q = query.toLowerCase().trim();
      return _buildFallbackCases().where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.abstract_.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q)) ||
          c.searchTokens.any((t) => t.contains(q))).toList();
    }
  }

  // ── Detay ──────────────────────────────────────────────────────────────
  @override
  Future<HubCaseEntity> getHubCaseById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;

    try {
      final doc = await _col.doc(id).get().timeout(_queryTimeout);
      if (!doc.exists) throw const HubCaseException('Vaka bulunamadı.');

      final uid = _uid;
      final isLiked = uid != null ? await _isLiked(id, uid) : false;
      final isBookmarked = uid != null ? await _isBookmarked(id, uid) : false;
      final entity = HubCaseModel.fromDoc(doc, isLiked: isLiked, isBookmarked: isBookmarked);
      _detailCache.set(id, entity);
      return entity;
    } catch (e) {
      // Firestore başarısız → seed data'dan bul
      debugPrint('[HUB_DETAIL] Firestore failed for $id, trying seed data: $e');
      final fallback = _findSeedCaseById(id);
      if (fallback != null) return fallback;
      throw HubCaseException('Vaka yüklenemedi: $e');
    }
  }

  // ── Oluşturma ──────────────────────────────────────────────────────────
  @override
  Future<HubCaseEntity> createHubCase({
    required String title,
    required String abstract_,
    required String content,
    required HubCaseCategory category,
    required String specialty,
    required HubDifficulty difficulty,
    required List<String> tags,
  }) async {
    final uid = _uid;
    if (uid == null) throw const HubCaseException('Oturum gerekli.');

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};

      final searchTokens = buildSearchTokens([title, abstract_, specialty, ...tags]);

      final docRef = _col.doc();
      final map = HubCaseModel.toCreateMap(
        title: title,
        abstract_: abstract_,
        content: content,
        category: category,
        specialty: specialty,
        difficulty: difficulty,
        tags: tags,
        authorId: uid,
        authorName: userData['displayName'] as String? ?? 'Anonim Doktor',
        authorSpecialty: userData['specialty'] as String? ?? specialty,
        authorPhotoUrl: userData['photoUrl'] as String?,
        searchTokens: searchTokens,
      );

      await docRef.set(map);
      // XP kazanımı
      await _incrementUserXp(uid, 30);
      // Cache temizle
      _listCache.clear();

      final created = await docRef.get();
      return HubCaseModel.fromDoc(created);
    } catch (e) {
      throw HubCaseException('Vaka oluşturulamadı: $e');
    }
  }

  // ── Beğeni ─────────────────────────────────────────────────────────────
  @override
  Future<void> likeHubCase(String caseId) async {
    final uid = _uid;
    if (uid == null) throw const HubCaseException('Oturum gerekli.');
    try {
      final batch = _firestore.batch();
      batch.set(
        _firestore.collection('hub_case_likes').doc('${caseId}_$uid'),
        {'caseId': caseId, 'userId': uid, 'likedAt': FieldValue.serverTimestamp()},
      );
      batch.update(_col.doc(caseId), {'likeCount': FieldValue.increment(1)});
      await batch.commit();
      _detailCache.invalidate(caseId);
    } catch (e) {
      throw HubCaseException('Beğeni eklenemedi: $e');
    }
  }

  @override
  Future<void> unlikeHubCase(String caseId) async {
    final uid = _uid;
    if (uid == null) throw const HubCaseException('Oturum gerekli.');
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('hub_case_likes').doc('${caseId}_$uid'));
      batch.update(_col.doc(caseId), {'likeCount': FieldValue.increment(-1)});
      await batch.commit();
      _detailCache.invalidate(caseId);
    } catch (e) {
      throw HubCaseException('Beğeni kaldırılamadı: $e');
    }
  }

  @override
  Future<bool> isHubCaseLiked(String caseId) async {
    final uid = _uid;
    if (uid == null) return false;
    return _isLiked(caseId, uid);
  }

  // ── Yer İmi ────────────────────────────────────────────────────────────
  @override
  Future<void> bookmarkHubCase(String caseId) async {
    final uid = _uid;
    if (uid == null) throw const HubCaseException('Oturum gerekli.');
    try {
      await _firestore.collection('hub_case_bookmarks').doc('${caseId}_$uid').set({
        'caseId': caseId,
        'userId': uid,
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
      _detailCache.invalidate(caseId);
    } catch (e) {
      throw HubCaseException('Yer imi eklenemedi: $e');
    }
  }

  @override
  Future<void> unbookmarkHubCase(String caseId) async {
    final uid = _uid;
    if (uid == null) throw const HubCaseException('Oturum gerekli.');
    try {
      await _firestore.collection('hub_case_bookmarks').doc('${caseId}_$uid').delete();
      _detailCache.invalidate(caseId);
    } catch (e) {
      throw HubCaseException('Yer imi kaldırılamadı: $e');
    }
  }

  @override
  Future<bool> isHubCaseBookmarked(String caseId) async {
    final uid = _uid;
    if (uid == null) return false;
    return _isBookmarked(caseId, uid);
  }

  // ── Görüntülenme ───────────────────────────────────────────────────────
  @override
  Future<void> incrementViewCount(String caseId) async {
    try {
      await _col.doc(caseId).update({'viewCount': FieldValue.increment(1)});
    } catch (_) {
      // Görüntülenme sayacı kritik değil, hata fırlatma
    }
  }

  // ── Private Helpers ────────────────────────────────────────────────────
  Future<bool> _isLiked(String caseId, String uid) async {
    final doc = await _firestore.collection('hub_case_likes').doc('${caseId}_$uid').get();
    return doc.exists;
  }

  Future<bool> _isBookmarked(String caseId, String uid) async {
    final doc = await _firestore.collection('hub_case_bookmarks').doc('${caseId}_$uid').get();
    return doc.exists;
  }

  Future<void> _incrementUserXp(String uid, int xp) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'totalXp': FieldValue.increment(xp),
        'xpThisWeek': FieldValue.increment(xp),
      });
    } catch (_) {}
  }
}
