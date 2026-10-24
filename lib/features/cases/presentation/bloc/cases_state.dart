part of 'cases_bloc.dart';

sealed class CasesState extends Equatable {
  const CasesState();
  @override
  List<Object?> get props => [];
}

class CasesInitial extends CasesState {
  const CasesInitial();
}

class CasesLoading extends CasesState {
  const CasesLoading();
}

class CasesLoaded extends CasesState {
  final List<CaseEntity> cases;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSearchResult;
  /// true = Firestore snapshot listener (real-time feed mode)
  final bool isLiveFeed;
  final String? activeFilter;
  final String? errorMessage; // refresh hatası için

  const CasesLoaded({
    required this.cases,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isSearchResult = false,
    this.isLiveFeed = false,
    this.activeFilter,
    this.errorMessage,
  });

  CasesLoaded copyWith({
    List<CaseEntity>? cases,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSearchResult,
    bool? isLiveFeed,
    String? activeFilter,
    String? errorMessage,
  }) =>
      CasesLoaded(
        cases: cases ?? this.cases,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isSearchResult: isSearchResult ?? this.isSearchResult,
        isLiveFeed: isLiveFeed ?? this.isLiveFeed,
        activeFilter: activeFilter ?? this.activeFilter,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [cases, hasMore, isLoadingMore, isLiveFeed, activeFilter, errorMessage];
}

class CasesError extends CasesState {
  final String message;
  const CasesError(this.message);

  @override
  List<Object?> get props => [message];
}
