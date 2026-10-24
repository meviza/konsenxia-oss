import '../entities/search_result.dart';

abstract class SearchRepository {
  /// Vakalar ve doktorlar arasında birleşik arama yapar.
  Future<List<SearchResult>> search(String query);

  /// Sadece doktorları arar.
  Future<List<SearchResult>> searchDoctors(String query);

  /// Sadece vakaları arar.
  Future<List<SearchResult>> searchCases(String query);
}
