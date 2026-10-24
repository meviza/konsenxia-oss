part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Dashboard verilerini ilk kez yükle
class LoadDashboardEvent extends DashboardEvent {
  const LoadDashboardEvent();
}

/// Feed'i yenile (pull-to-refresh)
class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent();
}
