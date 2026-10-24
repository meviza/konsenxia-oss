import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Firestore yapısı:
///   notifications/{uid}/items/{notifId}
///     type: string
///     title: string
///     body: string
///     timestamp: Timestamp
///     isRead: bool
///     actionRoute: string?
///     payload: Map?
class NotificationsRepositoryImpl implements NotificationsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Giriş yapılmamış');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore
          .collection('notifications')
          .doc(_uid)
          .collection('items');

  @override
  Stream<List<AppNotification>> watchNotifications() {
    try {
      return _items
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => _docToNotification(doc.data(), doc.id))
              .toList());
    } catch (e) {
      // If user is not logged in or Firestore is unreachable, return empty stream
      return Stream.value(<AppNotification>[]);
    }
  }

  @override
  Stream<int> watchUnreadCount() {
    return _items
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _items.doc(notificationId)
        .update({'isRead': true})
        .timeout(const Duration(seconds: 5));
  }

  @override
  Future<void> markAllAsRead() async {
    final unread = await _items
        .where('isRead', isEqualTo: false)
        .get()
        .timeout(const Duration(seconds: 5));
    if (unread.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit().timeout(const Duration(seconds: 5));
  }

  AppNotification _docToNotification(Map<String, dynamic> data, String id) {
    final ts = data['timestamp'];
    final timestamp = ts is Timestamp ? ts.toDate() : DateTime.now();

    final typeStr = data['type'] as String? ?? 'system';
    final type = NotificationType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => NotificationType.system,
    );

    return AppNotification(
      id: id,
      type: type,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timestamp: timestamp,
      isRead: data['isRead'] as bool? ?? false,
      actionRoute: data['actionRoute'] as String?,
      payload: data['payload'] as Map<String, dynamic>?,
    );
  }
}
