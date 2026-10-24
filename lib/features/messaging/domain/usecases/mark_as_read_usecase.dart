import '../repositories/messaging_repository.dart';

class MarkAsReadUseCase {
  final MessagingRepository _repository;
  const MarkAsReadUseCase(this._repository);

  Future<void> call(String conversationId) =>
      _repository.markAsRead(conversationId);
}
