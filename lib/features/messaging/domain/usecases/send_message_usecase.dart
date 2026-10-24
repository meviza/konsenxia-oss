import '../repositories/messaging_repository.dart';

class SendMessageUseCase {
  final MessagingRepository _repository;
  const SendMessageUseCase(this._repository);

  Future<void> call({required String toUserId, required String text}) =>
      _repository.sendMessage(toUserId: toUserId, text: text);
}
