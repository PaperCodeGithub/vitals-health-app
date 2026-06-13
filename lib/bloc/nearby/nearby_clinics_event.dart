abstract class NearbyClinicsEvent {}

class FetchClinicsByLocation extends NearbyClinicsEvent {
  final double latitude;
  final double longitude;
  final String? searchQuery;

  FetchClinicsByLocation({
    required this.latitude,
    required this.longitude,
    this.searchQuery,
  });
}