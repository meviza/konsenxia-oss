part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String role;

  const LoginEvent({
    required this.email,
    required this.password,
    this.role = 'RESIDENT',
  });

  @override
  List<Object?> get props => [email, password, role];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String specialty;
  final String institution;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.role = 'DOCTOR',
    this.specialty = '',
    this.institution = '',
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, role, specialty, institution];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class SwitchRoleEvent extends AuthEvent {
  final String newRole;

  const SwitchRoleEvent({required this.newRole});

  @override
  List<Object?> get props => [newRole];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}
