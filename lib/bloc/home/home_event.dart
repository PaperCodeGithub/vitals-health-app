abstract class HomeEvent {}

class FetchProfileEvent extends HomeEvent {
  final String accountType;
  FetchProfileEvent(this.accountType);
}

class ToggleEmergencyEvent extends HomeEvent {
  final bool currentStatus;
  ToggleEmergencyEvent(this.currentStatus);
}