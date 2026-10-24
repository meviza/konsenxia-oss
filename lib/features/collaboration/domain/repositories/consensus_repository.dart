import '../entities/poll_entity.dart';

class ConsensusException implements Exception {
  final String message;
  const ConsensusException(this.message);
  @override
  String toString() => 'ConsensusException: $message';
}

abstract interface class ConsensusRepository {
  /// Anketleri getirir. [status] null ise tüm anketler döner.
  Future<List<PollEntity>> getPolls({PollStatus? status});

  /// Belirli bir anketi real-time stream olarak izler.
  Stream<PollEntity> watchPoll(String pollId);

  /// Ankete oy kullanır. İkinci kez aynı seçenek → oy geri alınır.
  Future<void> voteOnPoll({required String pollId, required int optionIndex});
}
