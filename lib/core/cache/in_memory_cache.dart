/// KONSENXIA — TTL Destekli In-Memory Cache
///
/// Firestore okuma maliyetini azaltmak için kısa süreli önbellekleme.
/// Hub cases: 5dk, Polls: 2dk, Leaderboard: 3dk gibi kullanım senaryoları.
class InMemoryCache<T> {
  final Duration ttl;
  final Map<String, _CacheEntry<T>> _store = {};

  InMemoryCache({this.ttl = const Duration(minutes: 5)});

  /// Cache'e yaz
  void set(String key, T value) {
    _store[key] = _CacheEntry(value: value, expiresAt: DateTime.now().add(ttl));
  }

  /// Cache'den oku (null = miss veya süresi dolmuş)
  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Belirtilen key'i temizle
  void invalidate(String key) => _store.remove(key);

  /// Tüm cache'i temizle
  void clear() => _store.clear();

  /// Cache dolu mu kontrol et
  bool has(String key) => get(key) != null;
}

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  const _CacheEntry({required this.value, required this.expiresAt});
}
