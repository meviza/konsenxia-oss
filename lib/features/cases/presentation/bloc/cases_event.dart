part of 'cases_bloc.dart';

sealed class CasesEvent extends Equatable {
  const CasesEvent();
  @override
  List<Object?> get props => [];
}

class LoadCasesEvent extends CasesEvent {
  const LoadCasesEvent();
}

class LoadMoreCasesEvent extends CasesEvent {
  const LoadMoreCasesEvent();
}

class RefreshCasesEvent extends CasesEvent {
  const RefreshCasesEvent();
}

class FilterCasesEvent extends CasesEvent {
  final String? specialty;
  final String? urgency;
  final String? status;

  const FilterCasesEvent({this.specialty, this.urgency, this.status});

  @override
  List<Object?> get props => [specialty, urgency, status];
}

class SearchCasesEvent extends CasesEvent {
  final String query;
  const SearchCasesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Global case feed — real-time stream (Firestore snapshot listener)
class WatchFeedEvent extends CasesEvent {
  const WatchFeedEvent();
}

/// Kullanıcının kendi vakalarını yükle
class LoadUserCasesEvent extends CasesEvent {
  final String userId;
  const LoadUserCasesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Vaka beğen / beğeniyi kaldır
class ToggleLikeCaseEvent extends CasesEvent {
  final String caseId;
  final bool isCurrentlyLiked;
  const ToggleLikeCaseEvent({required this.caseId, required this.isCurrentlyLiked});

  @override
  List<Object?> get props => [caseId, isCurrentlyLiked];
}

/// Vaka kaydet / kaydı kaldır
class ToggleBookmarkCaseEvent extends CasesEvent {
  final String caseId;
  final bool isCurrentlyBookmarked;
  const ToggleBookmarkCaseEvent({required this.caseId, required this.isCurrentlyBookmarked});

  @override
  List<Object?> get props => [caseId, isCurrentlyBookmarked];
}
