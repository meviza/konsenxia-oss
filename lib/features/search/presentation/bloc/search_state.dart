part of 'search_bloc.dart';

enum SearchFilter { all, cases, doctors }

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  final String query;
  const SearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchLoaded extends SearchState {
  final String query;
  final List<SearchResult> results;
  final SearchFilter? activeFilter;

  const SearchLoaded({
    required this.query,
    required this.results,
    this.activeFilter,
  });

  List<SearchResult> get cases =>
      results.where((r) => r.type == SearchResultType.medicalCase).toList();

  List<SearchResult> get doctors =>
      results.where((r) => r.type == SearchResultType.doctor).toList();

  @override
  List<Object?> get props => [query, results, activeFilter];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
