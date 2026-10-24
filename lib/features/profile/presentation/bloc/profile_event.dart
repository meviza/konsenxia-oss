part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? displayName;
  final String? specialty;
  final String? bio;
  final String? institution;
  final String? title;

  const UpdateProfileEvent({
    this.displayName,
    this.specialty,
    this.bio,
    this.institution,
    this.title,
  });

  @override
  List<Object?> get props => [displayName, specialty, bio, institution, title];
}
