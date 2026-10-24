import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProfileRepositoryImpl({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference get _userDoc =>
      _db.collection('users').doc(_uid ?? 'anonymous');

  @override
  Future<void> updateProfile({
    String? displayName,
    String? specialty,
    String? bio,
    String? photoUrl,
    String? institution,
    String? title,
  }) async {
    if (_uid == null) throw const ProfileException('Oturum açmanız gerekiyor');

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (displayName != null) updates['displayName'] = displayName;
      if (specialty != null) updates['specialty'] = specialty;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (institution != null) updates['institution'] = institution;
      if (title != null) updates['title'] = title;

      await _userDoc.set(updates, SetOptions(merge: true));

      // Firebase Auth display name senkronizasyonu
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Profil güncellenemedi: $e');
    }
  }

  @override
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (_uid == null) return;
    try {
      await _userDoc.set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Online status sessizce başarısız olabilir
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? (doc.data() ?? {}) : {};
    } catch (e) {
      throw ProfileException('Profil yüklenemedi: $e');
    }
  }
}
