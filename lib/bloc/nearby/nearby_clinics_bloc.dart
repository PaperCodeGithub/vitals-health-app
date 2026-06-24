import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'nearby_clinics_event.dart';
import 'nearby_clinics_state.dart';

class NearbyClinicsBloc extends Bloc<NearbyClinicsEvent, NearbyClinicsState> {
  NearbyClinicsBloc() : super(ClinicsLoading()) {
    on<FetchClinicsByLocation>(_onFetchClinics);
  }

  Future<void> _onFetchClinics(FetchClinicsByLocation event, Emitter<NearbyClinicsState> emit) async {
    emit(ClinicsLoading());
    try {
      final GeoFirePoint center = GeoFirePoint(GeoPoint(event.latitude, event.longitude));
      const double searchRadiusKm = 10.0;

      // 1. Point to the new 'clinic' collection
      final collectionRef = FirebaseFirestore.instance.collection('clinic');

      // 2. Remove queryBuilder (no longer needed)
      // 3. Add .first at the end to convert the Stream to a Future
      List<DocumentSnapshot<Map<String, dynamic>>> docs = await GeoCollectionReference(collectionRef).fetchWithin(
        center: center,
        radiusInKm: searchRadiusKm,
        field: 'location',
        geopointFrom: (Map<String, dynamic> obj) {
          final locationMap = obj['location'] as Map<String, dynamic>;
          return locationMap['geopoint'] as GeoPoint;
        },
      );

      // Keep your search filter logic exactly as is
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final queryLower = event.searchQuery!.toLowerCase();
        docs = docs.where((doc) {
          final name = (doc.data()?['name'] as String? ?? '').toLowerCase();
          return name.contains(queryLower);
        }).toList();
      }

      emit(ClinicsLoaded(docs));
    } catch (e) {
      emit(ClinicsError(e.toString()));
      print(e.toString());
    }
  }
}