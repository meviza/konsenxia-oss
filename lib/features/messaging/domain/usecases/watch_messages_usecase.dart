import '../entities/direct_message.dart';
import '../repositories/messaging_repository.dart';

class WatchMessagesUseCase {
  final MessagingRepository _repository;
  const WatchMessagesUseCase(this._repository);

  Stream<List<DirectMessage>> call(String conversationId) =>
      _repository.watchMessages(conversationId);
}
