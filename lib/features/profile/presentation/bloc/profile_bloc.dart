import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../dashboard/domain/entities/dashboard_summary.dart';
import '../../../dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetDashboardSummaryUseCase _getSummary;
  final UpdateProfileUseCase _updateProfile;
  final SharedPreferences? _prefs;

  ProfileBloc({
    required GetDashboardSummaryUseCase getSummary,
    required UpdateProfileUseCase updateProfile,
    SharedPreferences? prefs,
  })  : _getSummary = getSummary,
        _updateProfile = updateProfile,
        _prefs = prefs,
        super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoad);
    on<UpdateProfileEvent>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final summary = await _getSummary();

      // Sync Firestore role to SharedPreferences so local state stays up-to-date
      if (summary.stats.role.isNotEmpty) {
        _syncRoleToLocal(summary.stats.role);
      }

      emit(ProfileLoaded(stats: summary.stats));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onUpdate(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));
    try {
      await _updateProfile(UpdateProfileParams(
        displayName: event.displayName,
        specialty: event.specialty,
        bio: event.bio,
        institution: event.institution,
        title: event.title,
      ));
      // Reload fresh data
      final summary = await _getSummary();

      // Sync role again after update
      if (summary.stats.role.isNotEmpty) {
        _syncRoleToLocal(summary.stats.role);
      }

      emit(ProfileLoaded(stats: summary.stats));
    } on ProfileException catch (e) {
      emit(current.copyWith(isUpdating: false, updateError: e.message));
    } catch (e) {
      emit(current.copyWith(isUpdating: false, updateError: e.toString()));
    }
  }

  /// Sync the Firestore role to SharedPreferences auth_user JSON
  void _syncRoleToLocal(String firestoreRole) {
    final prefs = _prefs;
    if (prefs == null) return;

    try {
      final userJson = prefs.getString('auth_user');
      if (userJson == null) return;

      final data = jsonDecode(userJson) as Map<String, dynamic>;
      final currentRole = data['role'] as String? ?? '';

      // Only update if the Firestore role differs from local
      if (currentRole != firestoreRole) {
        data['role'] = firestoreRole;
        prefs.setString('auth_user', jsonEncode(data));
      }
    } catch (_) {
      // Ignore JSON parse errors
    }
  }
}
