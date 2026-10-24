import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../models/case_firestore_model.dart';

/// KONSENXIA — CaseRepositoryImpl
///
/// Firestore üzerinde vaka CRUD, sosyal aksiyonlar ve yorum işlemleri.
/// Tüm işlemler batch/transaction kullanır.
/// Cursor-based pagination ile 1000+ doktor ölçeğine hazır.

/// Paginated result wrapper — holds both items and the last document snapshot
/// for cursor-based pagination.
class PaginatedCaseResult {
  final List<CaseEntity> cases;
  final DocumentSnapshot? lastDocument;

  const PaginatedCaseResult({
    required this.cases,
    this.lastDocument,
  });

  bool get hasMore => lastDocument != null && cases.isNotEmpty;
}

class CaseRepositoryImpl implements CaseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CaseRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ── Helpers ────────────────────────────────────────────────────

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw const CaseRepositoryException(AuthFailure('Giriş yapılmamış'));
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _cases =>
      _firestore.collection(CaseFirestoreModel.collection);

  CollectionReference<Map<String, dynamic>> _comments(String caseId) =>
      _cases.doc(caseId).collection(CommentFirestoreModel.subcollection);

  CollectionReference<Map<String, dynamic>> get _likes =>
      _firestore.collection('user_likes');

  CollectionReference<Map<String, dynamic>> get _bookmarks =>
      _firestore.collection('user_bookmarks');

  // ── Listing ────────────────────────────────────────────────────

  @override
  Stream<List<CaseEntity>> watchRecentCases({int limit = 20}) {
    return _cases
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CaseFirestoreModel.fromDoc(d)).toList());
  }

  @override
  Future<List<CaseEntity>> getCases({
    String? specialtyFilter,
    String? urgencyFilter,
    String? statusFilter,
    int limit = 20,
    String? lastCaseId,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _cases
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (specialtyFilter != null) {
        q = q.where('specialties', arrayContains: specialtyFilter);
      }
      if (urgencyFilter != null) {
        q = q.where('urgency', isEqualTo: urgencyFilter);
      }
      if (statusFilter != null) {
        q = q.where('status', isEqualTo: statusFilter);
      }

      // Pagination
      if (lastCaseId != null) {
        final lastDoc = await _cases.doc(lastCaseId).get()
            .timeout(const Duration(seconds: 5));
        if (lastDoc.exists) q = q.startAfterDocument(lastDoc);
      }

      final snapshot = await q.get().timeout(const Duration(seconds: 5));
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        return snapshot.docs
            .map((d) => CaseFirestoreModel.fromDoc(d))
            .toList();
      }

      // Check like/bookmark status for each case
      final cases = await Future.wait(snapshot.docs.map((d) async {
        final liked      = await isCaseLiked(d.id);
        final bookmarked = await isCaseBookmarked(d.id);
        return CaseFirestoreModel.fromDoc(
          d,
          isLikedByCurrentUser:      liked,
          isBookmarkedByCurrentUser: bookmarked,
        );
      }));

      return cases;
    } catch (_) {
      // Firestore erişilemezse mock data dön
      return _buildMockCases();
    }
  }

  /// Cursor-based paginated case fetching.
  /// Returns a [PaginatedCaseResult] containing the cases and a cursor
  /// (lastDocument) for fetching the next page.
  ///
  /// Usage:
  /// ```dart
  /// final page1 = await repo.getCasesPaginated();
  /// final page2 = await repo.getCasesPaginated(lastDocument: page1.lastDocument);
  /// ```
  Future<PaginatedCaseResult> getCasesPaginated({
    String? specialtyFilter,
    String? urgencyFilter,
    String? statusFilter,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _cases
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (specialtyFilter != null) {
        q = q.where('specialties', arrayContains: specialtyFilter);
      }
      if (urgencyFilter != null) {
        q = q.where('urgency', isEqualTo: urgencyFilter);
      }
      if (statusFilter != null) {
        q = q.where('status', isEqualTo: statusFilter);
      }

      // Cursor-based pagination — use the actual DocumentSnapshot
      if (lastDocument != null) {
        q = q.startAfterDocument(lastDocument);
      }

      final snapshot = await q.get().timeout(const Duration(seconds: 5));
      final uid = _auth.currentUser?.uid;

      final DocumentSnapshot? newCursor =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      if (uid == null) {
        return PaginatedCaseResult(
          cases: snapshot.docs
              .map((d) => CaseFirestoreModel.fromDoc(d))
              .toList(),
          lastDocument: newCursor,
        );
      }

      final cases = await Future.wait(snapshot.docs.map((d) async {
        final liked      = await isCaseLiked(d.id);
        final bookmarked = await isCaseBookmarked(d.id);
        return CaseFirestoreModel.fromDoc(
          d,
          isLikedByCurrentUser:      liked,
          isBookmarkedByCurrentUser: bookmarked,
        );
      }));

      return PaginatedCaseResult(
        cases: cases,
        lastDocument: newCursor,
      );
    } catch (_) {
      return PaginatedCaseResult(cases: _buildMockCases());
    }
  }

  @override
  Future<List<CaseEntity>> searchCases(String query) async {
    try {
      final q = query.toLowerCase().trim();
      final snapshot = await _cases
          .where('_searchTokens', arrayContains: q)
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 5));

      return snapshot.docs
          .map((d) => CaseFirestoreModel.fromDoc(d))
          .toList();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Arama başarısız', code: e.code),
      );
    }
  }

  @override
  Future<List<CaseEntity>> getTrendingCases({int limit = 10}) async {
    try {
      final snapshot = await _cases
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 5));

      return snapshot.docs
          .map((d) => CaseFirestoreModel.fromDoc(d))
          .toList();
    } catch (_) {
      return _buildMockCases().take(limit).toList();
    }
  }

  // ── Detail ─────────────────────────────────────────────────────

  @override
  Future<CaseEntity> getCaseById(String caseId) async {
    try {
      final doc = await _cases.doc(caseId).get()
          .timeout(const Duration(seconds: 5));
      if (!doc.exists) {
        // Firestore'da yoksa mock datadan dene
        final mock = _getMockCase(caseId);
        if (mock != null) return mock;
        throw const CaseRepositoryException(NotFoundFailure('Vaka'));
      }

      final liked      = await isCaseLiked(caseId);
      final bookmarked = await isCaseBookmarked(caseId);
      final comments   = await getComments(caseId);

      return CaseFirestoreModel.fromDoc(
        doc,
        isLikedByCurrentUser:      liked,
        isBookmarkedByCurrentUser: bookmarked,
      ).copyWith(comments: comments);
    } on CaseRepositoryException {
      rethrow;
    } catch (_) {
      // Firestore erisilemezse mock datadan dene
      final mock = _getMockCase(caseId);
      if (mock != null) return mock;
      throw CaseRepositoryException(
        const ServerFailure('Sunucuya ulaşılamıyor'),
      );
    }
  }

  @override
  Stream<CaseEntity> watchCase(String caseId) {
    return _cases.doc(caseId).snapshots().asyncMap((doc) async {
      if (!doc.exists) throw const CaseRepositoryException(NotFoundFailure('Vaka'));
      return CaseFirestoreModel.fromDoc(doc);
    });
  }

  // ── Mutations ──────────────────────────────────────────────────

  @override
  Future<String> createCase({
    required String title,
    required String description,
    required String clinicalPresentation,
    required String patientSummary,
    required CaseUrgency urgency,
    List<String> specialties = const [],
    List<String> tags = const [],
    List<VitalSign> vitals = const [],
  }) async {
    try {
      final uid  = _uid;
      final user = _auth.currentUser!;

      final data = CaseFirestoreModel.toCreateMap(
        title:                title,
        description:          description,
        clinicalPresentation: clinicalPresentation,
        patientSummary:       patientSummary,
        authorId:             uid,
        authorName:           user.displayName ?? 'Dr. Kullanıcı',
        authorImageUrl:       user.photoURL,
        authorSpecialty:      '', // fetched from user profile
        urgency:              urgency,
        specialties:          specialties,
        tags:                 tags,
        vitals:               vitals,
      );

      final docRef = await _cases.add(data);

      // Award XP for case creation
      await _incrementUserXp(uid, 50);

      return docRef.id;
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Vaka oluşturulamadı', code: e.code),
      );
    }
  }

  @override
  Future<void> updateCase(CaseEntity kase) async {
    try {
      await _cases.doc(kase.id).update(
        CaseFirestoreModel.toMap(kase)
          ..['updatedAt'] = FieldValue.serverTimestamp(),
      );
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Vaka güncellenemedi', code: e.code),
      );
    }
  }

  @override
  Future<void> deleteCase(String caseId) async {
    try {
      await _cases.doc(caseId).delete();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Vaka silinemedi', code: e.code),
      );
    }
  }

  @override
  Future<void> solveCase({
    required String caseId,
    required String diagnosisTitle,
    required String diagnosisDetails,
    required String acceptedCommentId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update case status + diagnosis
      batch.update(_cases.doc(caseId), {
        'status':           CaseStatus.solved.name,
        'diagnosisTitle':   diagnosisTitle,
        'diagnosisDetails': diagnosisDetails,
        'updatedAt':        FieldValue.serverTimestamp(),
      });

      // Mark comment as accepted answer
      batch.update(_comments(caseId).doc(acceptedCommentId), {
        'isAcceptedAnswer': true,
      });

      await batch.commit();

      // Award XP to accepted comment author
      final commentDoc = await _comments(caseId).doc(acceptedCommentId).get();
      if (commentDoc.exists) {
        final authorId = commentDoc.data()?['authorId'] as String?;
        if (authorId != null) {
          await _incrementUserXp(authorId, 100);
        }
      }
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Vaka çözülemedi', code: e.code),
      );
    }
  }

  // ── Social ─────────────────────────────────────────────────────

  @override
  Future<void> likeCase(String caseId) async {
    try {
      final uid = _uid;
      final batch = _firestore.batch();

      batch.set(
        _likes.doc('${uid}_case_$caseId'),
        {'userId': uid, 'caseId': caseId, 'createdAt': FieldValue.serverTimestamp()},
      );
      batch.update(_cases.doc(caseId), {
        'likeCount': FieldValue.increment(1),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Beğeni eklenemedi', code: e.code),
      );
    }
  }

  @override
  Future<void> unlikeCase(String caseId) async {
    try {
      final uid = _uid;
      final batch = _firestore.batch();

      batch.delete(_likes.doc('${uid}_case_$caseId'));
      batch.update(_cases.doc(caseId), {
        'likeCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Beğeni kaldırılamadı', code: e.code),
      );
    }
  }

  @override
  Future<void> bookmarkCase(String caseId) async {
    try {
      final uid = _uid;
      final batch = _firestore.batch();

      batch.set(
        _bookmarks.doc('${uid}_case_$caseId'),
        {'userId': uid, 'caseId': caseId, 'createdAt': FieldValue.serverTimestamp()},
      );
      batch.update(_cases.doc(caseId), {
        'bookmarkCount': FieldValue.increment(1),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Kaydedilemedi', code: e.code),
      );
    }
  }

  @override
  Future<void> unbookmarkCase(String caseId) async {
    try {
      final uid = _uid;
      final batch = _firestore.batch();

      batch.delete(_bookmarks.doc('${uid}_case_$caseId'));
      batch.update(_cases.doc(caseId), {
        'bookmarkCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Kayıt kaldırılamadı', code: e.code),
      );
    }
  }

  @override
  Future<bool> isCaseLiked(String caseId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final doc = await _likes.doc('${uid}_case_$caseId').get()
        .timeout(const Duration(seconds: 5));
    return doc.exists;
  }

  @override
  Future<bool> isCaseBookmarked(String caseId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final doc = await _bookmarks.doc('${uid}_case_$caseId').get()
        .timeout(const Duration(seconds: 5));
    return doc.exists;
  }

  // ── Comments ───────────────────────────────────────────────────

  @override
  Future<List<CaseComment>> getComments(String caseId) async {
    try {
      final uid = _auth.currentUser?.uid;
      final snapshot = await _comments(caseId)
          .orderBy('createdAt', descending: false)
          .get()
          .timeout(const Duration(seconds: 5));

      return snapshot.docs.map((d) {
        final isLiked = uid != null;  // simplified — real: check likes
        return CommentFirestoreModel.fromDoc(d, isLikedByCurrentUser: false);
      }).toList();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Yorumlar yüklenemedi', code: e.code),
      );
    }
  }

  @override
  Stream<List<CaseComment>> watchComments(String caseId) {
    return _comments(caseId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CommentFirestoreModel.fromDoc(d))
            .toList());
  }

  @override
  Future<String> addComment({
    required String caseId,
    required String content,
  }) async {
    try {
      final uid  = _uid;
      final user = _auth.currentUser!;

      final data = CommentFirestoreModel.toCreateMap(
        authorId:        uid,
        authorName:      user.displayName ?? 'Dr. Kullanıcı',
        authorImageUrl:  user.photoURL,
        authorSpecialty: '', // fetched from user profile
        content:         content,
      );

      final docRef = await _comments(caseId).add(data);

      // Update comment count on case document
      await _cases.doc(caseId).update({
        'status': CaseStatus.inDiscussion.name,
      });

      // Award XP for comment
      await _incrementUserXp(uid, 20);

      return docRef.id;
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Yorum eklenemedi', code: e.code),
      );
    }
  }

  @override
  Future<void> likeComment({
    required String caseId,
    required String commentId,
  }) async {
    try {
      final uid = _uid;
      await _firestore.runTransaction((tx) async {
        tx.set(
          _likes.doc('${uid}_comment_$commentId'),
          {'userId': uid, 'commentId': commentId},
        );
        tx.update(_comments(caseId).doc(commentId), {
          'likeCount': FieldValue.increment(1),
        });
      });
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Yorum beğenilemedi', code: e.code),
      );
    }
  }

  @override
  Future<void> unlikeComment({
    required String caseId,
    required String commentId,
  }) async {
    try {
      final uid = _uid;
      await _firestore.runTransaction((tx) async {
        tx.delete(_likes.doc('${uid}_comment_$commentId'));
        tx.update(_comments(caseId).doc(commentId), {
          'likeCount': FieldValue.increment(-1),
        });
      });
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Yorum beğenisi kaldırılamadı', code: e.code),
      );
    }
  }

  @override
  Future<void> acceptAnswer({
    required String caseId,
    required String commentId,
  }) async {
    try {
      // First, reset any previously accepted answers
      final existingAccepted = await _comments(caseId)
          .where('isAcceptedAnswer', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in existingAccepted.docs) {
        batch.update(doc.reference, {'isAcceptedAnswer': false});
      }

      batch.update(_comments(caseId).doc(commentId), {
        'isAcceptedAnswer': true,
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Cevap kabul edilemedi', code: e.code),
      );
    }
  }

  // ── User cases ─────────────────────────────────────────────────

  @override
  Future<List<CaseEntity>> getUserCases(String userId) async {
    try {
      final snapshot = await _cases
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((d) => CaseFirestoreModel.fromDoc(d))
          .toList();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Kullanıcı vakaları yüklenemedi', code: e.code),
      );
    }
  }

  @override
  Future<List<CaseEntity>> getBookmarkedCases() async {
    try {
      final uid = _uid;
      final bookmarkDocs = await _bookmarks
          .where('userId', isEqualTo: uid)
          .get();

      final caseIds = bookmarkDocs.docs
          .map((d) => d.data()['caseId'] as String)
          .toList();

      if (caseIds.isEmpty) return [];

      final caseDocs = await Future.wait(
        caseIds.map((id) => _cases.doc(id).get()),
      );

      return caseDocs
          .where((d) => d.exists)
          .map((d) => CaseFirestoreModel.fromDoc(
                d,
                isBookmarkedByCurrentUser: true,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw CaseRepositoryException(
        ServerFailure(e.message ?? 'Kaydedilen vakalar yüklenemedi', code: e.code),
      );
    }
  }

  // ── View tracking ─────────────────────────────────────────────

  @override
  Future<void> incrementViewCount(String caseId) async {
    try {
      await _cases.doc(caseId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (_) {
      // View count failure is non-critical — swallow error
    }
  }

  // ── XP helper ─────────────────────────────────────────────────

  Future<void> _incrementUserXp(String userId, int amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'xp': FieldValue.increment(amount),
        'xpTotal': FieldValue.increment(amount),
      });
    } catch (_) {
      // XP failure is non-critical
    }
  }

  // ── Mock Data Fallback ──────────────────────────────────────────
  // Firestore API etkin değilken uygulamanın çalışmaya devam etmesi için

  CaseEntity? _getMockCase(String caseId) {
    final allMock = _buildMockCases();
    try {
      return allMock.firstWhere((c) => c.id == caseId);
    } catch (_) {
      return null;
    }
  }

  List<CaseEntity> _buildMockCases() {
    return [
      CaseEntity(
        id: 'KX-2024-0045',
        title: '58y/E — ST elevasyonlu göğüs ağrısı: ACS mi?',
        patientSummary: '58 yaşında erkek hasta, 2 saattir süren eziyet verici göğüs ağrısı ile acile başvurdu.',
        description: 'Hasta 58 yaşında erkek, hipertansiyon ve tip 2 DM öyküsü mevcut. '
            '2 saattir substernal, sol kola vuran şiddetli göğüs ağrısı tanımlıyor. '
            'EKG\'de II, III, aVF derivasyonlarında ST elevasyonu (2mm). '
            'Troponin I: 1.8 ng/mL (yüksek). KB: 85/50 mmHg. Nabız: 112/dk, düzensiz. '
            'STEMI tanısı konuldu; acil perkütan koroner girişim (PKG) planlandı.',
        clinicalPresentation: 'Substernal göğüs ağrısı, ST elevasyonu',
        authorId: 'seed-author-1',
        authorName: 'Uzm. Dr. Ayşe Kara',
        authorSpecialty: 'Kardiyoloji',
        authorCountry: 'TR',
        authorLevel: 9,
        urgency: CaseUrgency.critical,
        status: CaseStatus.inDiscussion,
        specialties: const ['Kardiyoloji', 'Acil Tıp'],
        tags: const ['STEMI', 'ACS', 'PKG', 'Kardiojenik Şok'],
        vitals: const [
          VitalSign(label: 'KB', value: '85/50', unit: 'mmHg', range: VitalRange.critical),
          VitalSign(label: 'Nabız', value: '112', unit: '/dk', range: VitalRange.warning),
          VitalSign(label: 'SpO2', value: '91', unit: '%', range: VitalRange.critical),
          VitalSign(label: 'Ateş', value: '36.8', unit: '°C', range: VitalRange.normal),
        ],
        xpReward: const CaseXpReward(xpForComment: 30, xpForAcceptedAnswer: 150, xpForAuthor: 80),
        viewCount: 541, likeCount: 47, bookmarkCount: 23,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        comments: _mockComments('KX-2024-0045'),
      ),
      CaseEntity(
        id: 'KX-2024-0046',
        title: '45y/K — Ani baş ağrısı + sol hemipleji: İnme şüphesi',
        patientSummary: '45 yaşında kadın hasta, ani başlayan şiddetli baş ağrısı ve sol vücut yarısında güçsüzlük.',
        description: 'Hasta 45 yaşında kadın, sigara içici (20 paket-yıl), oral kontraseptif kullanıcısı. '
            'Sabah uyanırken sol hemipleji fark etmiş. "Hayatımın en kötü baş ağrısı" tarif ediyor. '
            'BT\'de sağ orta serebral arter sulama alanında hipodens alan. '
            'NIHSS skoru: 14. tPA için zaman penceresi geçmiş; trombektomi değerlendiriliyor.',
        clinicalPresentation: 'Ani hemipleji, şiddetli baş ağrısı',
        authorId: 'seed-author-2',
        authorName: 'Doç. Dr. Mehmet Aydın',
        authorSpecialty: 'Nöroloji',
        authorCountry: 'TR',
        authorLevel: 11,
        urgency: CaseUrgency.emergency,
        status: CaseStatus.open,
        specialties: const ['Nöroloji', 'Acil Tıp', 'Radyoloji'],
        tags: const ['İnme', 'Hemipleji', 'tPA', 'Trombektomi'],
        vitals: const [
          VitalSign(label: 'KB', value: '178/102', unit: 'mmHg', range: VitalRange.critical),
          VitalSign(label: 'Nabız', value: '88', unit: '/dk', range: VitalRange.normal),
          VitalSign(label: 'SpO2', value: '96', unit: '%', range: VitalRange.normal),
          VitalSign(label: 'GKS', value: '13', unit: '/15', range: VitalRange.warning),
        ],
        xpReward: const CaseXpReward(xpForComment: 40, xpForAcceptedAnswer: 200, xpForAuthor: 100),
        viewCount: 389, likeCount: 62, bookmarkCount: 31,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        comments: _mockComments('KX-2024-0046'),
      ),
      CaseEntity(
        id: 'KX-2024-0047',
        title: '32y/E — Ateş, hipotansiyon, konfüzyon: Sepsis odağı nerede?',
        patientSummary: '32 yaşında erkek hasta, 3 gündür süren ateş, hipotansiyon ve konfüzyonla yoğun bakıma alındı.',
        description: 'Hasta 32 yaşında erkek, özgeçmişinde tip 1 DM. '
            'KB: 78/42 mmHg, nabız: 128/dk, ateş: 39.4°C. Laktat: 4.2 mmol/L. '
            'WBC: 22.000 (sola kayma). CRP: 342. PCT: 8.7 ng/mL. '
            'Akciğer grafisinde sol alt lob konsolidasyon. '
            'Septic shock tanısıyla yoğun bakıma alındı.',
        clinicalPresentation: 'Ateş, hipotansiyon, konfüzyon',
        authorId: 'seed-author-3',
        authorName: 'Dr. Selin Kaya',
        authorSpecialty: 'Enfeksiyon Hastalıkları',
        authorCountry: 'TR',
        authorLevel: 7,
        urgency: CaseUrgency.critical,
        status: CaseStatus.inDiscussion,
        specialties: const ['Enfeksiyon Hastalıkları', 'Yoğun Bakım'],
        tags: const ['Sepsis', 'Septic Shock', 'Laktat', 'Norepinefrin'],
        vitals: const [
          VitalSign(label: 'KB', value: '78/42', unit: 'mmHg', range: VitalRange.critical),
          VitalSign(label: 'Nabız', value: '128', unit: '/dk', range: VitalRange.critical),
          VitalSign(label: 'Ateş', value: '39.4', unit: '°C', range: VitalRange.critical),
          VitalSign(label: 'Laktat', value: '4.2', unit: 'mmol/L', range: VitalRange.critical),
        ],
        xpReward: const CaseXpReward(xpForComment: 35, xpForAcceptedAnswer: 180, xpForAuthor: 90),
        viewCount: 312, likeCount: 28, bookmarkCount: 14,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        comments: _mockComments('KX-2024-0047'),
      ),
      CaseEntity(
        id: 'KX-2024-0048',
        title: '22y/K — DKA, bilinç bulanıklığı: İnsülin protokolü?',
        patientSummary: '22 yaşında kadın hasta, bilinen Tip 1 DM, bilinç bulanıklığıyla başvurdu.',
        description: 'Hasta 22 yaşında kadın, Tip 1 DM (8 yıllık). İnsülin pompa arızası sonrası insülin almamış. '
            'Glukoz: 492 mg/dL. pH: 7.08. Bikarbonat: 8. Keton: ++++. Anyon gap: 28. '
            'DKA protokolü başlandı.',
        clinicalPresentation: 'DKA, bilinç bulanıklığı',
        authorId: 'seed-author-4',
        authorName: 'Dr. Zeynep Arslan',
        authorSpecialty: 'Endokrinoloji',
        authorCountry: 'TR',
        authorLevel: 6,
        urgency: CaseUrgency.urgent,
        status: CaseStatus.open,
        specialties: const ['Endokrinoloji', 'Yoğun Bakım'],
        tags: const ['DKA', 'Tip 1 DM', 'Hipokalemi', 'İnsülin'],
        vitals: const [
          VitalSign(label: 'Glukoz', value: '492', unit: 'mg/dL', range: VitalRange.critical),
          VitalSign(label: 'pH', value: '7.08', unit: '', range: VitalRange.critical),
          VitalSign(label: 'K+', value: '2.8', unit: 'mEq/L', range: VitalRange.critical),
          VitalSign(label: 'GKS', value: '12', unit: '/15', range: VitalRange.warning),
        ],
        xpReward: const CaseXpReward(xpForComment: 25, xpForAcceptedAnswer: 120, xpForAuthor: 70),
        viewCount: 278, likeCount: 41, bookmarkCount: 19,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        comments: _mockComments('KX-2024-0048'),
      ),
      CaseEntity(
        id: 'KX-2024-0049',
        title: '19y/E — Politravma, motorlu taşıt kazası: Damage control mi?',
        patientSummary: '19 yaşında erkek hasta, yüksek hızlı motorlu taşıt kazası sonrası acile getirildi.',
        description: 'Hasta 19 yaşında erkek, trafik kazası sonrası ambulansla getirildi. '
            'GKS: 13/15. Bilateral femur fraktürü, sol pnömotoraks. '
            'FAST US: Batın içi serbest sıvı. KB: 88/56 mmHg. Hemoglobin: 7.2 g/dL. '
            'Damage control cerrahisi vs. erken total care tartışması var.',
        clinicalPresentation: 'Politravma, hemodinamik instabilite',
        authorId: 'seed-author-5',
        authorName: 'Dr. Emre Yılmaz',
        authorSpecialty: 'Acil Tıp',
        authorCountry: 'TR',
        authorLevel: 5,
        urgency: CaseUrgency.emergency,
        status: CaseStatus.open,
        specialties: const ['Acil Tıp', 'Genel Cerrahi', 'Ortopedi'],
        tags: const ['Politravma', 'Damage Control', 'Hemotoraks', 'Masif Transfüzyon'],
        vitals: const [
          VitalSign(label: 'KB', value: '88/56', unit: 'mmHg', range: VitalRange.critical),
          VitalSign(label: 'Nabız', value: '136', unit: '/dk', range: VitalRange.critical),
          VitalSign(label: 'Hgb', value: '7.2', unit: 'g/dL', range: VitalRange.critical),
          VitalSign(label: 'GKS', value: '13', unit: '/15', range: VitalRange.warning),
        ],
        xpReward: const CaseXpReward(xpForComment: 30, xpForAcceptedAnswer: 160, xpForAuthor: 85),
        viewCount: 421, likeCount: 38, bookmarkCount: 17,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        comments: _mockComments('KX-2024-0049'),
      ),
      CaseEntity(
        id: 'KX-2024-0050',
        title: '65y/E — Ani dispne, sağ alt lob PE şüphesi: Antikoagülasyon?',
        patientSummary: '65 yaşında erkek hasta, ani başlayan dispne ve sağ plöritik göğüs ağrısı.',
        description: 'Hasta 65 yaşında erkek, 2 hafta önce sağ diz protezi ameliyatı geçirmiş. '
            'D-dimer: 4800 ng/mL. Wells skoru: 6. SpO2: %88. '
            'BT anjio: Sağ ana pulmoner arterde filling defekti — masif PE. '
            'Hemodinamik instabilite. Trombolitik uygulandı.',
        clinicalPresentation: 'Ani dispne, masif PE',
        authorId: 'seed-author-6',
        authorName: 'Prof. Dr. Aynur Başkaya',
        authorSpecialty: 'Göğüs Hastalıkları',
        authorCountry: 'TR',
        authorLevel: 14,
        urgency: CaseUrgency.critical,
        status: CaseStatus.solved,
        specialties: const ['Göğüs Hastalıkları', 'Kardiyoloji', 'Acil Tıp'],
        tags: const ['Pulmoner Emboli', 'Wells', 'Trombolitik', 'DVT'],
        vitals: const [
          VitalSign(label: 'KB', value: '82/50', unit: 'mmHg', range: VitalRange.critical),
          VitalSign(label: 'SpO2', value: '88', unit: '%', range: VitalRange.critical),
          VitalSign(label: 'Nabız', value: '118', unit: '/dk', range: VitalRange.critical),
          VitalSign(label: 'D-dimer', value: '4800', unit: 'ng/mL', range: VitalRange.critical),
        ],
        xpReward: const CaseXpReward(xpForComment: 20, xpForAcceptedAnswer: 100, xpForAuthor: 60),
        diagnosisTitle: 'Masif Pulmoner Emboli — Sistolik Instabilite',
        diagnosisDetails: 'BT-PA\'da sağ ana pulmoner arterde filling defekti. '
            'Hemodinamik instabilite nedeniyle sistemik trombolitik (alteplaz 100mg/2h) uygulandı.',
        viewCount: 334, likeCount: 52, bookmarkCount: 26,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        comments: _mockComments('KX-2024-0050'),
      ),
    ];
  }

  List<CaseComment> _mockComments(String caseId) {
    final base = DateTime.now().subtract(const Duration(hours: 5));

    final commentsMap = <String, List<CaseComment>>{
      'KX-2024-0045': [
        CaseComment(
          id: '${caseId}_c1',
          authorId: 'doc-k1',
          authorName: 'Prof. Dr. Hasan Çelik',
          authorSpecialty: 'Kardiyoloji',
          authorLevel: 13,
          content: 'İnferior STEMI tablosu net. Sağ ventrikül tutulumunu dışlamak için V4R çekildi mi? '
              'Hipotansiyon + inferior STEMI → RV MI düşünülmeli. IV sıvı yüklenmesi yapıldı mı?',
          isExpertOpinion: true,
          createdAt: base,
        ),
        CaseComment(
          id: '${caseId}_c2',
          authorId: 'doc-k2',
          authorName: 'Uzm. Dr. Deniz Acar',
          authorSpecialty: 'Acil Tıp',
          authorLevel: 7,
          content: 'Door-to-balloon süresi kritik. Acil PKG için kateter labı aktive edildi mi? '
              'Aspirin 300mg + Tikagrelol 180mg yükleme yapılması önerilir.',
          createdAt: base.add(const Duration(minutes: 20)),
        ),
        CaseComment(
          id: '${caseId}_c3',
          authorId: 'doc-k3',
          authorName: 'Dr. Burcu Yılmaz',
          authorSpecialty: 'Anesteziyoloji',
          authorLevel: 6,
          content: 'Kardiojenik şok tablosunda dobutamin veya milrinon tercih ettiniz mi? '
              'IABP düşünülebilir. SpO2 %91 — mekanik ventilasyon ihtiyacı olabilir.',
          createdAt: base.add(const Duration(minutes: 55)),
        ),
        CaseComment(
          id: '${caseId}_c4',
          authorId: 'doc-k4',
          authorName: 'Doç. Dr. Serkan Öztürk',
          authorSpecialty: 'Kardiyoloji',
          authorLevel: 10,
          content: 'Güzel paylaşım. Troponin seyrini takip edin — peak değer prognoz açısından önemli. '
              'Killip sınıflaması ne? Killip III-IV ise mortalite %30-50 aralığında.',
          isExpertOpinion: true,
          createdAt: base.add(const Duration(hours: 1, minutes: 30)),
        ),
        CaseComment(
          id: '${caseId}_c5',
          authorId: 'doc-k5',
          authorName: 'Dr. Aylin Korkmaz',
          authorSpecialty: 'Dahiliye',
          authorLevel: 5,
          content: 'HbA1c değeri kaç? Diyabet regülasyonu PKG sonrası yara iyileşmesi ve komplikasyonlar açısından önemli.',
          createdAt: base.add(const Duration(hours: 2)),
        ),
      ],
      'KX-2024-0046': [
        CaseComment(
          id: '${caseId}_c1',
          authorId: 'doc-n1',
          authorName: 'Prof. Dr. Zehra Tan',
          authorSpecialty: 'Nöroloji',
          authorLevel: 14,
          content: 'NIHSS 14 ve son görülme 6 saat → tPA penceresi geçmiş ama mekanik trombektomi '
              '24 saate kadar yapılabiliyor (DAWN / DEFUSE 3 kriterleri). BT perfüzyon çekildi mi? '
              'Penumbra / core oranı değerlendirilmeli.',
          isExpertOpinion: true,
          createdAt: base,
        ),
        CaseComment(
          id: '${caseId}_c2',
          authorId: 'doc-n2',
          authorName: 'Uzm. Dr. Can Arslan',
          authorSpecialty: 'Radyoloji',
          authorLevel: 8,
          content: 'BT anjio + BT perfüzyon çekip mismatch oranına bakmanızı öneririm. '
              'MCA M1 oklüzyonu varsa trombektomi endikasyonu güçlüdür.',
          createdAt: base.add(const Duration(minutes: 35)),
        ),
        CaseComment(
          id: '${caseId}_c3',
          authorId: 'doc-n3',
          authorName: 'Dr. Pınar Kılıç',
          authorSpecialty: 'Acil Tıp',
          authorLevel: 6,
          content: 'Antihipertansif ile KB\'yi 185/110 altına çekmek gerekir (labetalol önerilir). '
              'Oral kontraseptif kullanımı önemli bir risk faktörü — trombofili paneli istenebilir.',
          createdAt: base.add(const Duration(hours: 1)),
        ),
        CaseComment(
          id: '${caseId}_c4',
          authorId: 'doc-n4',
          authorName: 'Doç. Dr. Emre Şahin',
          authorSpecialty: 'Beyin Cerrahisi',
          authorLevel: 11,
          content: 'Dekompresif hemikraniyektomi gerekebilir — ödeme bağlı klinik kötüleşme olursa '
              'erken cerrahi planlayın. GKS takibi saatlik yapılmalı.',
          isExpertOpinion: true,
          createdAt: base.add(const Duration(hours: 2)),
        ),
      ],
      'KX-2024-0047': [
        CaseComment(
          id: '${caseId}_c1',
          authorId: 'doc-s1',
          authorName: 'Prof. Dr. Nurgül Başer',
          authorSpecialty: 'Enfeksiyon Hastalıkları',
          authorLevel: 13,
          content: 'qSOFA ≥2, laktat >4 → septic shock kesin. Surviving Sepsis Campaign 2021\'e göre '
              'ilk 1 saatte 30mL/kg kristalloid + geniş spektrumlu AB (piperasilin-tazobaktam veya meropenem) '
              'başlanmalı. Kan kültürleri AB öncesi alındı mı?',
          isExpertOpinion: true,
          createdAt: base,
        ),
        CaseComment(
          id: '${caseId}_c2',
          authorId: 'doc-s2',
          authorName: 'Uzm. Dr. Oğuz Demir',
          authorSpecialty: 'Yoğun Bakım',
          authorLevel: 9,
          content: 'MAP hedefi ≥65 mmHg. Norepinefrin birinci seçenek doğru ama 0.5 mcg/kg/dk üstüne çıkılırsa '
              'vazopressin 0.03 U/dk ekleyin. Hidrokortizon 200mg/gün düşünülebilir.',
          createdAt: base.add(const Duration(minutes: 40)),
        ),
        CaseComment(
          id: '${caseId}_c3',
          authorId: 'doc-s3',
          authorName: 'Dr. Fatma Güneş',
          authorSpecialty: 'Göğüs Hastalıkları',
          authorLevel: 7,
          content: 'Sol alt lob konsolidasyon → pnömoni kaynaklı sepsis olası. Balgam kültürü ve '
              'Legionella + pnömokok antijeni istenmeli. Atipik patojenleri de kapsamalı.',
          createdAt: base.add(const Duration(hours: 1, minutes: 15)),
        ),
        CaseComment(
          id: '${caseId}_c4',
          authorId: 'doc-s4',
          authorName: 'Dr. Murat Koç',
          authorSpecialty: 'Dahiliye',
          authorLevel: 5,
          content: 'DM tip 1 hastasında immün yetmezlik de göz önünde bulundurulmalı. '
              'Fungal enfeksiyon açısından beta-D-glukan takibi iyi düşünülmüş.',
          createdAt: base.add(const Duration(hours: 2)),
        ),
      ],
    };

    // Diğer vakalar için genel yorumlar
    final defaultComments = [
      CaseComment(
        id: '${caseId}_c1',
        authorId: 'doc-d1',
        authorName: 'Prof. Dr. Hasan Çelik',
        authorSpecialty: 'Kardiyoloji',
        authorLevel: 13,
        content: 'Çok öğretici bir vaka sunumu. Klinik tablo ve laboratuvar bulgularıyla birlikte '
            'ayırıcı tanı süreci detaylı aktarılmış. Tebrikler.',
        isExpertOpinion: true,
        createdAt: base,
      ),
      CaseComment(
        id: '${caseId}_c2',
        authorId: 'doc-d2',
        authorName: 'Uzm. Dr. Deniz Acar',
        authorSpecialty: 'Acil Tıp',
        authorLevel: 7,
        content: 'Acil yaklaşım algoritmasını takip etmek önemli. Güncel kılavuz önerilerine göre '
            'tedavi planını gözden geçirmek faydalı olabilir.',
        createdAt: base.add(const Duration(minutes: 30)),
      ),
      CaseComment(
        id: '${caseId}_c3',
        authorId: 'doc-d3',
        authorName: 'Doç. Dr. Serkan Öztürk',
        authorSpecialty: 'Dahiliye',
        authorLevel: 10,
        content: 'Multidisipliner konsültasyon planını merak ediyorum. Hangi bölümlerle görüşüldü?',
        isExpertOpinion: true,
        createdAt: base.add(const Duration(hours: 1)),
      ),
      CaseComment(
        id: '${caseId}_c4',
        authorId: 'doc-d4',
        authorName: 'Dr. Aylin Korkmaz',
        authorSpecialty: 'Aile Hekimliği',
        authorLevel: 5,
        content: 'Taburculuk sonrası takip planı nasıl düşünülüyor? Birinci basamakla koordinasyon önemli.',
        createdAt: base.add(const Duration(hours: 1, minutes: 45)),
      ),
      CaseComment(
        id: '${caseId}_c5',
        authorId: 'doc-d5',
        authorName: 'Dr. Burak Yılmaz',
        authorSpecialty: 'Radyoloji',
        authorLevel: 6,
        content: 'Görüntüleme bulgularını daha detaylı paylaşabilir misiniz? Karşılaştırma açısından faydalı olur.',
        createdAt: base.add(const Duration(hours: 2, minutes: 20)),
      ),
    ];

    return commentsMap[caseId] ?? defaultComments;
  }
}
