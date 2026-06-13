import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NearbyClinicsState {}

class ClinicsLoading extends NearbyClinicsState {}

class ClinicsLoaded extends NearbyClinicsState {
  final List<DocumentSnapshot<Map<String, dynamic>>> clinics;
  ClinicsLoaded(this.clinics);
}

class ClinicsError extends NearbyClinicsState {
  final String message;
  ClinicsError(this.message);
}