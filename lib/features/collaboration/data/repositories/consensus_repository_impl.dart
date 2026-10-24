import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/repositories/consensus_repository.dart';
import '../models/poll_model.dart';

class ConsensusRepositoryImpl implements ConsensusRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ConsensusRepositoryImpl({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _polls => _db.collection('polls');
  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<List<PollEntity>> getPolls({PollStatus? status}) async {
    try {
      Query query = _polls.orderBy('createdAt', descending: true).limit(50);
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final snapshot = await query.get();
      final uid = _uid;

      final futures = snapshot.docs.map((doc) async {
        int? myVoteIndex;
        if (uid != null) {
          final voteDoc =
              await _polls.doc(doc.id).collection('votes').doc(uid).get();
          if (voteDoc.exists) {
            myVoteIndex =
                (voteDoc.data() as Map<String, dynamic>)['optionIndex'] as int?;
          }
        }
        return PollModel.fromDoc(doc, myVoteIndex: myVoteIndex);
      });

      return await Future.wait(futures);
    } catch (e) {
      throw ConsensusException('Oylamalar yüklenemedi: $e');
    }
  }

  @override
  Stream<PollEntity> watchPoll(String pollId) {
    return _polls.doc(pollId).snapshots().asyncMap((doc) async {
      if (!doc.exists) throw ConsensusException('Oylama bulunamadı');
      final uid = _uid;
      int? myVoteIndex;
      if (uid != null) {
        final voteDoc =
            await _polls.doc(pollId).collection('votes').doc(uid).get();
        if (voteDoc.exists) {
          myVoteIndex =
              (voteDoc.data() as Map<String, dynamic>)['optionIndex'] as int?;
        }
      }
      return PollModel.fromDoc(doc, myVoteIndex: myVoteIndex);
    });
  }

  @override
  Future<void> voteOnPoll({
    required String pollId,
    required int optionIndex,
  }) async {
    final uid = _uid;
    if (uid == null) throw const ConsensusException('Oturum açmanız gerekiyor');

    try {
      final pollRef = _polls.doc(pollId);
      final voteRef = pollRef.collection('votes').doc(uid);
      final voteDoc = await voteRef.get();

      await _db.runTransaction((tx) async {
        final pollSnap = await tx.get(pollRef);
        if (!pollSnap.exists) throw const ConsensusException('Oylama bulunamadı');

        final data = pollSnap.data() as Map<String, dynamic>;
        final options = List<Map<String, dynamic>>.from(
            (data['options'] as List).map((o) => Map<String, dynamic>.from(o)));
        var totalVotes = (data['totalVotes'] as num?)?.toInt() ?? 0;

        if (voteDoc.exists) {
          // Önceki oy varsa geri al
          final prevIndex =
              (voteDoc.data() as Map<String, dynamic>)['optionIndex'] as int?;
          if (prevIndex != null && prevIndex < options.length) {
            options[prevIndex]['voteCount'] =
                ((options[prevIndex]['voteCount'] as num?)?.toInt() ?? 1) - 1;
            totalVotes = (totalVotes - 1).clamp(0, totalVotes);
          }
          tx.delete(voteRef);
          if (prevIndex == optionIndex) {
            // Aynı seçeneğe tekrar tıklandı → oy iptal
            tx.update(pollRef, {
              'options': options,
              'totalVotes': totalVotes,
            });
            return;
          }
        }

        // Yeni oy ekle
        if (optionIndex < options.length) {
          options[optionIndex]['voteCount'] =
              ((options[optionIndex]['voteCount'] as num?)?.toInt() ?? 0) + 1;
          totalVotes++;
        }

        tx.set(voteRef, {
          'optionIndex': optionIndex,
          'votedAt': FieldValue.serverTimestamp(),
        });
        tx.update(pollRef, {
          'options': options,
          'totalVotes': totalVotes,
        });
      });
    } catch (e) {
      if (e is ConsensusException) rethrow;
      throw ConsensusException('Oy kullanılamadı: $e');
    }
  }
}
