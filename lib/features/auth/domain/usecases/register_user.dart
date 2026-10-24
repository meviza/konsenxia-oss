import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository _repository;

  RegisterUser(this._repository);

  Future<User> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) {
    return _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
  }
}
