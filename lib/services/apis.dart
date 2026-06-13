
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService instance = DatabaseService._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUid => _auth.currentUser?.uid ?? '';

  bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<bool> doesUserExist() async {
    final DocumentSnapshot snapshot = await _db.collection('users').doc(_currentUid).get();
    return snapshot.exists;
  }

  Future<String> getAccountType() async {
    final DocumentSnapshot snapshot = await _db.collection('users').doc(_currentUid).get();
    return snapshot.get('accountType');
  }

  Future<void> createPatientProfile({
    required String name,
    required String age,
    required String gender,
    required String height,
    required String weight,
    required String bloodGroup,
  }) async {
    if(_currentUid.isEmpty) throw Exception("User is not logged in or uid is empty");

    return await _db.collection('users').doc(_currentUid).set({
      'accountType': 'patient',
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bloodGroup': bloodGroup,
    });
  }

  Future<void> createClinicProfile({
    required String name,
    required double lat,
    required double lng,
    required String address,
    required String phone,
    required String license,
    required String hours,
    required String fee,
    required bool emergency,
  }) async {
    if(_currentUid.isEmpty) throw Exception("User is not logged in or uid is empty");

    final GeoFirePoint clinicLocation = GeoFirePoint(GeoPoint(lat, lng));

    return await _db.collection('users').doc(_currentUid).set({
      'accountType': 'clinic',
      'name': name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'phone': phone,
      'license': license,
      'hours': hours,
      'fee': fee,
      'emergency': false,
      'location' : clinicLocation.data,
    });
  }

  Future<DocumentSnapshot> getProfile() async {
    final DocumentSnapshot snapshot = await _db.collection('users').doc(_currentUid).get();
    return snapshot;
  }

  Future<void> updatePatientProfile({
    required String name,
    required String age,
    required String gender,
    required String height,
    required String weight,
    required String bloodGroup,

  }) async {
    if(_currentUid.isEmpty) throw Exception("User is not logged in or uid is empty");

    return await _db.collection('users').doc(_currentUid).update({
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bloodGroup': bloodGroup,
    });
  }

  Future<void> updateClinicProfile({
    required String name,
    required double lat,
    required double lng,
    required String address,
    required String phone,
    required String license,
    required String hours,
    required String fee,
    required bool emergency,
  }) async {
    if(_currentUid.isEmpty) throw Exception("User is not logged in or uid is empty");

    GeoFirePoint clinicLocation = GeoFirePoint(GeoPoint(lat, lng));

    return await _db.collection('users').doc(_currentUid).update({
      'name': name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'phone': phone,
      'license': license,
      'hours': hours,
      'fee': fee,
      'emergency': emergency,
      'location' : clinicLocation.data,
    });
  }

  Future<Position> determineLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<String>> getNearbyClinicIDs(double userLat, double userLng) async {
    final GeoFirePoint center = GeoFirePoint(GeoPoint(userLat, userLng));
    const double searchRadiusKm = 10.0;

    final collectionRef = FirebaseFirestore.instance.collection('users');

    final List<DocumentSnapshot<Map<String, dynamic>>> docs =
    await GeoCollectionReference(collectionRef)
        .fetchWithin(
        center: center,
        radiusInKm: searchRadiusKm,
        field: 'location',
        queryBuilder: (query) => query.where('accountType', isEqualTo: 'clinic'),
                geopointFrom: (Map<String, dynamic> obj) {
                  final locationMap = obj['location'] as Map<String, dynamic>;
                  return locationMap['geopoint'] as GeoPoint;
                },
    );

    return docs.map((doc) => doc.id).toList();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

}