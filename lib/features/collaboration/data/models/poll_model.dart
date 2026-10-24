import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/poll_entity.dart';

class PollModel {
  static PollEntity fromDoc(
    DocumentSnapshot doc, {
    int? myVoteIndex,
  }) {
    final data = doc.data() as Map<String, dynamic>;

    final rawOptions = (data['options'] as List<dynamic>? ?? []);
    final options = rawOptions.map((o) {
      final m = o as Map<String, dynamic>;
      return PollOptionEntity(
        label: m['label'] as String? ?? '',
        voteCount: (m['voteCount'] as num?)?.toInt() ?? 0,
        rationale: m['rationale'] as String? ?? '',
      );
    }).toList();

    return PollEntity(
      id: doc.id,
      caseRef: data['caseRef'] as String? ?? '',
      question: data['question'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      options: options,
      expertComment: data['expertComment'] as String?,
      expertName: data['expertName'] as String?,
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: PollStatus.fromValue(data['status'] as String? ?? 'open'),
      totalVotes: (data['totalVotes'] as num?)?.toInt() ?? 0,
      myVoteIndex: myVoteIndex,
      authorId: data['authorId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String caseRef,
    required String question,
    required String specialty,
    required List<PollOptionEntity> options,
    required String authorId,
    required DateTime deadline,
    String? expertComment,
    String? expertName,
  }) {
    return {
      'caseRef': caseRef,
      'question': question,
      'specialty': specialty,
      'options': options
          .map((o) => {
                'label': o.label,
                'voteCount': 0,
                'rationale': o.rationale,
              })
          .toList(),
      'expertComment': expertComment,
      'expertName': expertName,
      'deadline': Timestamp.fromDate(deadline),
      'status': 'open',
      'totalVotes': 0,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
