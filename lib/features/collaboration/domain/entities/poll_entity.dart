import 'package:equatable/equatable.dart';

/// KONSENXIA Konsensüs — Oylama Entity
class PollEntity extends Equatable {
  final String id;
  final String caseRef;
  final String question;
  final String specialty;
  final List<PollOptionEntity> options;
  final String? expertComment;
  final String? expertName;
  final DateTime deadline;
  final PollStatus status;
  final int totalVotes;
  final int? myVoteIndex; // null = oy kullanılmadı
  final String authorId;
  final DateTime createdAt;

  const PollEntity({
    required this.id,
    required this.caseRef,
    required this.question,
    required this.specialty,
    required this.options,
    this.expertComment,
    this.expertName,
    required this.deadline,
    required this.status,
    required this.totalVotes,
    this.myVoteIndex,
    required this.authorId,
    required this.createdAt,
  });

  bool get hasVoted => myVoteIndex != null;

  PollEntity copyWith({
    List<PollOptionEntity>? options,
    int? totalVotes,
    int? myVoteIndex,
    PollStatus? status,
  }) {
    return PollEntity(
      id: id,
      caseRef: caseRef,
      question: question,
      specialty: specialty,
      options: options ?? this.options,
      expertComment: expertComment,
      expertName: expertName,
      deadline: deadline,
      status: status ?? this.status,
      totalVotes: totalVotes ?? this.totalVotes,
      myVoteIndex: myVoteIndex ?? this.myVoteIndex,
      authorId: authorId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, caseRef, question, specialty, options,
        expertComment, expertName, deadline, status,
        totalVotes, myVoteIndex, authorId, createdAt,
      ];
}

class PollOptionEntity extends Equatable {
  final String label;
  final int voteCount;
  final String rationale;

  const PollOptionEntity({
    required this.label,
    required this.voteCount,
    required this.rationale,
  });

  PollOptionEntity copyWith({int? voteCount}) =>
      PollOptionEntity(label: label, voteCount: voteCount ?? this.voteCount, rationale: rationale);

  @override
  List<Object?> get props => [label, voteCount, rationale];
}

enum PollStatus {
  open,
  voting,
  solved;

  String get label => switch (this) {
        PollStatus.open   => 'Açık',
        PollStatus.voting => 'Oylamada',
        PollStatus.solved => 'Çözüldü',
      };

  static PollStatus fromValue(String v) => switch (v) {
        'voting' => PollStatus.voting,
        'solved' => PollStatus.solved,
        _        => PollStatus.open,
      };
}
