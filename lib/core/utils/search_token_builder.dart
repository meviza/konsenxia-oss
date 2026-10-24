/// KONSENXIA — Prefix Search Token Üreteci
///
/// Firestore'da array-contains sorgusu için arama token'ları üretir.
/// Örnek: "Semaglutid" → ["s", "se", "sem", "sema", "semal", ...]
///
/// Bu pattern cases feature'dan alınmıştır (case_repository_impl).
List<String> buildSearchTokens(List<String> fields) {
  final tokens = <String>{};

  for (final field in fields) {
    final normalized = field.toLowerCase().trim();
    if (normalized.isEmpty) continue;

    // Her kelime için prefix token'ları üret
    for (final word in normalized.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      for (int i = 1; i <= word.length; i++) {
        tokens.add(word.substring(0, i));
      }
    }

    // Tam cümle için de token üret (birleşik arama)
    final combined = normalized.replaceAll(RegExp(r'\s+'), '');
    for (int i = 1; i <= combined.length && i <= 20; i++) {
      tokens.add(combined.substring(0, i));
    }
  }

  return tokens.toList();
}
