import 'package:equatable/equatable.dart';
import '../../domain/entities/hub_case_entity.dart';

abstract class HubCasesEvent extends Equatable {
  const HubCasesEvent();
  @override
  List<Object?> get props => [];
}

class LoadHubCasesEvent extends HubCasesEvent {
  final HubCaseCategory? category;
  const LoadHubCasesEvent({this.category});
  @override
  List<Object?> get props => [category];
}

class LoadMoreHubCasesEvent extends HubCasesEvent {
  const LoadMoreHubCasesEvent();
}

class RefreshHubCasesEvent extends HubCasesEvent {
  const RefreshHubCasesEvent();
}

class FilterHubCasesEvent extends HubCasesEvent {
  final HubCaseCategory category;
  const FilterHubCasesEvent(this.category);
  @override
  List<Object?> get props => [category];
}

class SearchHubCasesEvent extends HubCasesEvent {
  final String query;
  const SearchHubCasesEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class LikeHubCaseEvent extends HubCasesEvent {
  final String caseId;
  final bool isCurrentlyLiked;
  const LikeHubCaseEvent({required this.caseId, required this.isCurrentlyLiked});
  @override
  List<Object?> get props => [caseId, isCurrentlyLiked];
}
