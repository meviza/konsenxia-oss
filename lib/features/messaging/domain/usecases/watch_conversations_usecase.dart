import '../entities/conversation.dart';
import '../repositories/messaging_repository.dart';

class WatchConversationsUseCase {
  final MessagingRepository _repository;
  const WatchConversationsUseCase(this._repository);

  Stream<List<Conversation>> call() => _repository.watchConversations();
}
