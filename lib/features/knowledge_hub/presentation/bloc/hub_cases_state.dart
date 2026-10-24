import 'package:equatable/equatable.dart';
import '../../domain/entities/hub_case_entity.dart';

abstract class HubCasesState extends Equatable {
  const HubCasesState();
  @override
  List<Object?> get props => [];
}

class HubCasesInitial extends HubCasesState {
  const HubCasesInitial();
}

class HubCasesLoading extends HubCasesState {
  const HubCasesLoading();
}

class HubCasesLoaded extends HubCasesState {
  final List<HubCaseEntity> cases;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSearchResult;
  final HubCaseCategory activeCategory;
  final String? errorMessage;

  const HubCasesLoaded({
    required this.cases,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isSearchResult = false,
    this.activeCategory = HubCaseCategory.all,
    this.errorMessage,
  });

  HubCasesLoaded copyWith({
    List<HubCaseEntity>? cases,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSearchResult,
    HubCaseCategory? activeCategory,
    String? errorMessage,
  }) {
    return HubCasesLoaded(
      cases: cases ?? this.cases,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearchResult: isSearchResult ?? this.isSearchResult,
      activeCategory: activeCategory ?? this.activeCategory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    cases, hasMore, isLoadingMore, isSearchResult, activeCategory, errorMessage,
  ];
}

class HubCasesError extends HubCasesState {
  final String message;
  const HubCasesError(this.message);
  @override
  List<Object?> get props => [message];
}
