import 'package:equatable/equatable.dart';

abstract class HubCaseDetailEvent extends Equatable {
  const HubCaseDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadHubCaseDetailEvent extends HubCaseDetailEvent {
  final String caseId;
  const LoadHubCaseDetailEvent(this.caseId);
  @override
  List<Object?> get props => [caseId];
}

class LikeHubCaseDetailEvent extends HubCaseDetailEvent {
  const LikeHubCaseDetailEvent();
}

class BookmarkHubCaseDetailEvent extends HubCaseDetailEvent {
  const BookmarkHubCaseDetailEvent();
}
