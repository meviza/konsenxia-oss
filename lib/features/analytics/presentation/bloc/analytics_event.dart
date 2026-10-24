part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {
  const LoadAnalyticsEvent();
}

class RefreshAnalyticsEvent extends AnalyticsEvent {
  const RefreshAnalyticsEvent();
}
