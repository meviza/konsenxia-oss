import 'package:equatable/equatable.dart';

/// KONSENXIA — Use Case Temel Sınıfı
///
/// Tüm use case'ler bu abstract sınıfı implement eder.
/// [Type] = dönüş tipi, [Params] = parametre tipi
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Parametre gerektirmeyen use case'ler için
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
