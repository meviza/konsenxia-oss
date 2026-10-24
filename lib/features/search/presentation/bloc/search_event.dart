part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class QueryChangedEvent extends SearchEvent {
  final String query;
  const QueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class FilterChangedEvent extends SearchEvent {
  final SearchFilter? filter;
  const FilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}
