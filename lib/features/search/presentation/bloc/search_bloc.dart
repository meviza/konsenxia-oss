import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _repository;

  SearchBloc({required SearchRepository repository})
      : _repository = repository,
        super(const SearchInitial()) {
    on<QueryChangedEvent>(_onQuery, transformer: _debounce());
    on<ClearSearchEvent>(_onClear);
    on<FilterChangedEvent>(_onFilter);
  }

  EventTransformer<QueryChangedEvent> _debounce() {
    return (events, mapper) => events
        .distinct()
        .debounce(const Duration(milliseconds: 350))
        .asyncExpand(mapper);
  }

  Future<void> _onQuery(
    QueryChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(SearchLoading(query: query));
    try {
      final filter = state is SearchLoaded
          ? (state as SearchLoaded).activeFilter
          : null;

      final results = filter == SearchFilter.cases
          ? await _repository.searchCases(query)
          : filter == SearchFilter.doctors
              ? await _repository.searchDoctors(query)
              : await _repository.search(query);

      emit(SearchLoaded(
        query: query,
        results: results,
        activeFilter: filter,
      ));
    } catch (e) {
      emit(const SearchError('Arama yapılamadı. Bağlantınızı kontrol edin.'));
    }
  }

  Future<void> _onClear(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchInitial());
  }

  Future<void> _onFilter(
    FilterChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final query = state is SearchLoaded
        ? (state as SearchLoaded).query
        : state is SearchLoading
            ? (state as SearchLoading).query
            : '';

    if (query.isEmpty) {
      emit(SearchLoaded(
        query: '',
        results: const [],
        activeFilter: event.filter,
      ));
      return;
    }

    emit(SearchLoading(query: query));
    try {
      final results = event.filter == SearchFilter.cases
          ? await _repository.searchCases(query)
          : event.filter == SearchFilter.doctors
              ? await _repository.searchDoctors(query)
              : await _repository.search(query);

      emit(SearchLoaded(
        query: query,
        results: results,
        activeFilter: event.filter,
      ));
    } catch (e) {
      emit(const SearchError('Arama yapılamadı. Bağlantınızı kontrol edin.'));
    }
  }
}

extension _DebounceExt<T> on Stream<T> {
  Stream<T> debounce(Duration duration) {
    StreamController<T>? controller;
    Timer? timer;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          (event) {
            timer?.cancel();
            timer = Timer(duration, () => controller!.add(event));
          },
          onError: controller!.addError,
          onDone: controller!.close,
        );
      },
      onCancel: () {
        timer?.cancel();
        subscription?.cancel();
      },
      sync: true,
    );
    return controller.stream;
  }

  Stream<T> distinct() async* {
    T? last;
    bool hasLast = false;
    await for (final event in this) {
      if (!hasLast || event != last) {
        hasLast = true;
        last = event;
        yield event;
      }
    }
  }
}
