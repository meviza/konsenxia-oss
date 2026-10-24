import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  final ProfileRepository repository;
  const UpdateProfileUseCase(this.repository);

  @override
  Future<void> call(UpdateProfileParams params) => repository.updateProfile(
        displayName: params.displayName,
        specialty: params.specialty,
        bio: params.bio,
        photoUrl: params.photoUrl,
        institution: params.institution,
        title: params.title,
      );
}

class UpdateProfileParams extends Equatable {
  final String? displayName;
  final String? specialty;
  final String? bio;
  final String? photoUrl;
  final String? institution;
  final String? title;

  const UpdateProfileParams({
    this.displayName,
    this.specialty,
    this.bio,
    this.photoUrl,
    this.institution,
    this.title,
  });

  @override
  List<Object?> get props =>
      [displayName, specialty, bio, photoUrl, institution, title];
}
