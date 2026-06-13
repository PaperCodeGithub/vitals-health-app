abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final String bloodGroup;
  final String weight;
  final String height;
  final String gender;
  final bool isEmergency;
  final String dailyFact;

  HomeLoaded({
    required this.userName,
    required this.bloodGroup,
    required this.weight,
    required this.height,
    required this.gender,
    required this.isEmergency,
    required this.dailyFact,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}