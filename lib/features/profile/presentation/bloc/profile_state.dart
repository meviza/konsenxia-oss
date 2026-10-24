part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserStats stats;
  final bool isUpdating;
  final String? updateError;

  const ProfileLoaded({
    required this.stats,
    this.isUpdating = false,
    this.updateError,
  });

  ProfileLoaded copyWith({
    UserStats? stats,
    bool? isUpdating,
    String? updateError,
  }) =>
      ProfileLoaded(
        stats: stats ?? this.stats,
        isUpdating: isUpdating ?? this.isUpdating,
        updateError: updateError,
      );

  @override
  List<Object?> get props => [stats, isUpdating, updateError];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
