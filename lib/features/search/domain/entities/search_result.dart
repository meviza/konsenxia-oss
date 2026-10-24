import 'package:equatable/equatable.dart';

enum SearchResultType { medicalCase, doctor }

/// Birlesik arama sonucu (vaka veya doktor)
class SearchResult extends Equatable {
  final String id;
  final SearchResultType type;
  final String title;       // Vaka basligi veya doktor adi
  final String subtitle;    // Uzmanlik veya vaka ozeti
  final String? imageUrl;
  final String? route;      // Navigasyon hedefi
  final String? role;       // Doktor rolu (PROFESSOR, SPECIALIST, RESIDENT, INTERN)
  final String? institution; // Kurum

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.route,
    this.role,
    this.institution,
  });

  @override
  List<Object?> get props => [id, type];
}
