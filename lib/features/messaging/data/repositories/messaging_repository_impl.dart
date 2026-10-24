import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/direct_message.dart';
import '../../domain/repositories/messaging_repository.dart';

/// Firestore koleksiyon yapısı:
///   conversations/{convId}
///     participants: [uid1, uid2]
///     participantNames: {uid: displayName}
///     participantSpecialties: {uid: specialty}
///     participantPhotos: {uid: photoUrl?}
///     lastMessage: {text, senderId, timestamp}
///     unreadCounts: {uid: int}
///     updatedAt: timestamp
///
///   conversations/{convId}/messages/{msgId}
///     senderId: string
///     text: string
///     timestamp: timestamp
///     isRead: bool
class MessagingRepositoryImpl implements MessagingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MessagingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Giriş yapılmamış');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _convs =>
      _firestore.collection('conversations');

  // ── Konuşma listesi (real-time) ────────────────────────────────

  @override
  Stream<List<Conversation>> watchConversations() {
    final uid = _uid;
    return _convs
        .where('participants', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => _docToConversation(doc.data(), doc.id, uid))
            .toList());
  }

  Conversation _docToConversation(
    Map<String, dynamic> data,
    String id,
    String myUid,
  ) {
    final participants = List<String>.from(data['participants'] as List? ?? []);
    final otherUid = participants.firstWhere(
      (p) => p != myUid,
      orElse: () => myUid,
    );

    final names =
        Map<String, dynamic>.from(data['participantNames'] as Map? ?? {});
    final specs =
        Map<String, dynamic>.from(data['participantSpecialties'] as Map? ?? {});
    final photos =
        Map<String, dynamic>.from(data['participantPhotos'] as Map? ?? {});

    final lastMsg = data['lastMessage'] as Map<String, dynamic>?;
    final unreadCounts =
        Map<String, dynamic>.from(data['unreadCounts'] as Map? ?? {});
    final unread = (unreadCounts[myUid] as int?) ?? 0;

    DateTime? lastAt;
    if (lastMsg?['timestamp'] is Timestamp) {
      lastAt = (lastMsg!['timestamp'] as Timestamp).toDate();
    }

    return Conversation(
      id: id,
      otherUserId: otherUid,
      otherUserName: names[otherUid] as String? ?? 'Doktor',
      otherUserPhotoUrl: photos[otherUid] as String?,
      otherUserSpecialty: specs[otherUid] as String? ?? '',
      lastMessageText: lastMsg?['text'] as String?,
      lastMessageAt: lastAt,
      lastMessageSenderId: lastMsg?['senderId'] as String?,
      unreadCount: unread,
    );
  }

  // ── Mesajlar (real-time) ────────────────────────────────────────

  @override
  Stream<List<DirectMessage>> watchMessages(String conversationId) {
    return _convs
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => _docToMessage(doc.data(), doc.id, conversationId))
            .toList());
  }

  DirectMessage _docToMessage(
    Map<String, dynamic> data,
    String id,
    String conversationId,
  ) {
    final ts = data['timestamp'];
    final timestamp =
        ts is Timestamp ? ts.toDate() : DateTime.now();
    return DirectMessage(
      id: id,
      conversationId: conversationId,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: timestamp,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  // ── Mesaj gönder ────────────────────────────────────────────────

  @override
  Future<void> sendMessage({
    required String toUserId,
    required String text,
  }) async {
    final uid = _uid;
    final convId = await getOrCreateConversationId(toUserId);

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    // Yeni mesaj belgesi
    final msgRef = _convs.doc(convId).collection('messages').doc();
    batch.set(msgRef, {
      'senderId': uid,
      'text': text,
      'timestamp': now,
      'isRead': false,
    });

    // Konuşma meta güncelle
    batch.update(_convs.doc(convId), {
      'lastMessage': {
        'text': text,
        'senderId': uid,
        'timestamp': now,
      },
      'updatedAt': now,
      // Alıcının okunmamış sayacını artır
      'unreadCounts.$toUserId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ── Okundu işaretle ────────────────────────────────────────────

  @override
  Future<void> markAsRead(String conversationId) async {
    final uid = _uid;
    await _convs.doc(conversationId).update({
      'unreadCounts.$uid': 0,
    });
    // Bireysel mesajları da okundu yap
    final unread = await _convs
        .doc(conversationId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: uid)
        .get();
    if (unread.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Konuşma oluştur / getir ─────────────────────────────────────

  @override
  Future<String> getOrCreateConversationId(String otherUserId) async {
    final uid = _uid;

    // Mevcut konuşmayı ara
    final existing = await _convs
        .where('participants', arrayContains: uid)
        .get();

    for (final doc in existing.docs) {
      final participants =
          List<String>.from(doc.data()['participants'] as List? ?? []);
      if (participants.contains(otherUserId)) return doc.id;
    }

    // Yoksa oluştur — karşı tarafın profilini al
    final otherDoc = await _firestore.collection('users').doc(otherUserId).get();
    final myDoc = await _firestore.collection('users').doc(uid).get();

    final myData = myDoc.data() ?? {};
    final otherData = otherDoc.data() ?? {};

    final convRef = _convs.doc();
    await convRef.set({
      'participants': [uid, otherUserId],
      'participantNames': {
        uid: myData['displayName'] ?? 'Doktor',
        otherUserId: otherData['displayName'] ?? 'Doktor',
      },
      'participantSpecialties': {
        uid: myData['specialty'] ?? '',
        otherUserId: otherData['specialty'] ?? '',
      },
      'participantPhotos': {
        uid: myData['photoUrl'],
        otherUserId: otherData['photoUrl'],
      },
      'lastMessage': null,
      'unreadCounts': {uid: 0, otherUserId: 0},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return convRef.id;
  }
}
