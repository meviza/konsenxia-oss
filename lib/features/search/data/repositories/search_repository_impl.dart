import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<SearchResult>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final results = await Future.wait([
      searchCases(q),
      searchDoctors(q),
    ]);

    return [...results[0], ...results[1]];
  }

  @override
  Future<List<SearchResult>> searchCases(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final snap = await _firestore
        .collection('cases')
        .where('_searchTokens', arrayContains: q)
        .limit(10)
        .get()
        .timeout(const Duration(seconds: 5));

    return snap.docs.map((doc) {
      final data = doc.data();
      return SearchResult(
        id: doc.id,
        type: SearchResultType.medicalCase,
        title: data['title'] as String? ?? '',
        subtitle: data['specialty'] as String? ?? '',
        route: '/cases/${doc.id}',
      );
    }).toList();
  }

  @override
  Future<List<SearchResult>> searchDoctors(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final capitalized = q[0].toUpperCase() + q.substring(1);

    // Run multiple search strategies in parallel to find users
    // Web signup writes: firstName, lastName, displayName, role, specialty, institution, email
    // Some users may have displayNameLower, some may not
    final snapshots = await Future.wait([
      // Strategy 1: displayNameLower prefix (for users that have this field)
      _safeQuery(
        _firestore.collection('users')
            .where('displayNameLower', isGreaterThanOrEqualTo: q)
            .where('displayNameLower', isLessThan: '${q}\uf8ff')
            .limit(10),
      ),
      // Strategy 2: displayName prefix (lowercase)
      _safeQuery(
        _firestore.collection('users')
            .where('displayName', isGreaterThanOrEqualTo: q)
            .where('displayName', isLessThan: '${q}\uf8ff')
            .limit(10),
      ),
      // Strategy 3: displayName prefix with capitalized first letter
      _safeQuery(
        _firestore.collection('users')
            .where('displayName', isGreaterThanOrEqualTo: capitalized)
            .where('displayName', isLessThan: '${capitalized}\uf8ff')
            .limit(10),
      ),
      // Strategy 4: specialty prefix search
      _safeQuery(
        _firestore.collection('users')
            .where('specialty', isGreaterThanOrEqualTo: capitalized)
            .where('specialty', isLessThan: '${capitalized}\uf8ff')
            .limit(10),
      ),
      // Strategy 5: email prefix search
      _safeQuery(
        _firestore.collection('users')
            .where('email', isGreaterThanOrEqualTo: q)
            .where('email', isLessThan: '${q}\uf8ff')
            .limit(10),
      ),
      // Strategy 6: firstName prefix search
      _safeQuery(
        _firestore.collection('users')
            .where('firstName', isGreaterThanOrEqualTo: capitalized)
            .where('firstName', isLessThan: '${capitalized}\uf8ff')
            .limit(10),
      ),
      // Strategy 7: lastName prefix search
      _safeQuery(
        _firestore.collection('users')
            .where('lastName', isGreaterThanOrEqualTo: capitalized)
            .where('lastName', isLessThan: '${capitalized}\uf8ff')
            .limit(10),
      ),
    ]);

    // Deduplicate results by doc ID
    final seen = <String>{};
    final results = <SearchResult>[];

    for (final docs in snapshots) {
      for (final doc in docs) {
        if (seen.contains(doc.id)) continue;
        seen.add(doc.id);

        final data = doc.data();
        final displayName = data['displayName'] as String? ?? '';
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        final name = displayName.isNotEmpty
            ? displayName
            : '$firstName $lastName'.trim();
        final specialty = data['specialty'] as String? ?? '';
        final role = data['role'] as String? ?? '';
        final institution = data['institution'] as String? ?? '';

        // Build subtitle: role + specialty + institution
        final roleTr = _roleToTurkish(role);
        final subtitleParts = <String>[];
        if (roleTr.isNotEmpty) subtitleParts.add(roleTr);
        if (specialty.isNotEmpty) subtitleParts.add(specialty);
        if (institution.isNotEmpty) subtitleParts.add(institution);

        results.add(SearchResult(
          id: doc.id,
          type: SearchResultType.doctor,
          title: name.isNotEmpty ? name : (data['email'] as String? ?? 'Doktor'),
          subtitle: subtitleParts.join(' \u00b7 '),
          imageUrl: data['photoUrl'] as String?,
          route: '/messages',
          role: role,
          institution: institution,
        ));
      }
    }

    return results;
  }

  /// Safely execute a Firestore query, returning empty list on error
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _safeQuery(
      Query<Map<String, dynamic>> query) async {
    try {
      final snap = await query.get().timeout(const Duration(seconds: 5));
      return snap.docs;
    } catch (_) {
      return [];
    }
  }

  String _roleToTurkish(String role) => switch (role) {
    'PROFESSOR'  => 'Prof. Dr.',
    'SPECIALIST' => 'Uzm. Dr.',
    'RESIDENT'   => 'Asistan Dr.',
    'INTERN'     => 'Intern',
    _            => '',
  };
}
