import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo_service;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../bloc/nearby/nearby_clinics_bloc.dart';
import '../../bloc/nearby/nearby_clinics_event.dart';
import '../../bloc/nearby/nearby_clinics_state.dart';

class NearbyDoctorsScreen extends StatelessWidget {
  const NearbyDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NearbyClinicsBloc(),
      child: const _NearbyDoctorsView(),
    );
  }
}

class _NearbyDoctorsView extends StatefulWidget {
  const _NearbyDoctorsView();

  @override
  State<_NearbyDoctorsView> createState() => _NearbyDoctorsViewState();
}

class _NearbyDoctorsViewState extends State<_NearbyDoctorsView> {
  GoogleMapController? _mapController;
  LatLng? _mapCenterPosition;
  bool _isLocating = true;
  bool _isSearchingLocation = false;
  String _permissionMessage = "";

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _determineInitialPosition();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _determineInitialPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLocating = false;
        _permissionMessage = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLocating = false;
          _permissionMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocating = false;
        _permissionMessage = "Location permissions are permanently denied.";
      });
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );

    if (mounted) {
      setState(() {
        _mapCenterPosition = LatLng(position.latitude, position.longitude);
        _isLocating = false;
      });

      context.read<NearbyClinicsBloc>().add(
          FetchClinicsByLocation(latitude: position.latitude, longitude: position.longitude)
      );
    }
  }

  void _onSearchLocationChanged(String textAddress) {
    if (textAddress.trim().isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      setState(() => _isSearchingLocation = true);

      try {
        List<geo_service.Location> locations = await geo_service.locationFromAddress(textAddress);

        if (locations.isNotEmpty && mounted) {
          final targetLat = locations.first.latitude;
          final targetLng = locations.first.longitude;
          final newCenter = LatLng(targetLat, targetLng);

          setState(() {
            _mapCenterPosition = newCenter;
            _isSearchingLocation = false;
          });

          _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(newCenter, 14.0)
          );

          context.read<NearbyClinicsBloc>().add(
              FetchClinicsByLocation(latitude: targetLat, longitude: targetLng)
          );
        }
      } catch (e) {
        setState(() => _isSearchingLocation = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final glassColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.05);
    final borderColor = isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);

    if (_isLocating) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CupertinoActivityIndicator(radius: 16, color: textColor)),
      );
    }

    if (_mapCenterPosition == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text(_permissionMessage, style: TextStyle(color: textColor))),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          BlocBuilder<NearbyClinicsBloc, NearbyClinicsState>(
            builder: (context, state) {
              Set<Marker> markers = {};

              if (state is ClinicsLoaded) {
                markers = state.clinics.map((doc) {
                  final data = doc.data()!;
                  final locationData = data['location'] as Map<String, dynamic>;
                  final geoPoint = locationData['geopoint'] as GeoPoint;

                  return Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(geoPoint.latitude, geoPoint.longitude),
                    infoWindow: InfoWindow(title: data['name'] ?? 'Clinic'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                  );
                }).toSet();
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _mapCenterPosition!,
                  zoom: 14.0,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              );
            },
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: glassColor,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: borderColor),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchLocationChanged,
                              style: TextStyle(color: textColor, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "Enter area, city, or zip...",
                                hintStyle: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14),
                                prefixIcon: Icon(CupertinoIcons.location_solid, color: Theme.of(context).colorScheme.primary, size: 20),
                                suffixIcon: _isSearchingLocation
                                    ? Transform.scale(scale: 0.5, child: CupertinoActivityIndicator(color: textColor))
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.40,
            child: GestureDetector(
              onTap: () async {
                final currentGps = await Geolocator.getCurrentPosition();
                final homeCoords = LatLng(currentGps.latitude, currentGps.longitude);

                setState(() => _mapCenterPosition = homeCoords);
                _searchController.clear();

                _mapController?.animateCamera(CameraUpdate.newLatLng(homeCoords));
                if (mounted) {
                  context.read<NearbyClinicsBloc>().add(
                      FetchClinicsByLocation(latitude: currentGps.latitude, longitude: currentGps.longitude)
                  );
                }
              },
              child: _buildFrostedCircle(CupertinoIcons.location_fill, glassColor, borderColor, textColor),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (BuildContext context, ScrollController scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(isDark ? 0.85 : 0.95),
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: BlocBuilder<NearbyClinicsBloc, NearbyClinicsState>(
                      builder: (context, state) {
                        return CustomScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 16, bottom: 24),
                                  width: 50, height: 5,
                                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Nearby Clinics", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                                    if (state is ClinicsLoaded)
                                      Text("${state.clinics.length} found", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),

                            if (state is ClinicsLoading)
                              const SliverFillRemaining(
                                child: Center(child: CupertinoActivityIndicator()),
                              )
                            else if (state is ClinicsError)
                              SliverToBoxAdapter(
                                child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(state.message, style: const TextStyle(color: Colors.red)))),
                              )
                            else if (state is ClinicsLoaded)
                                state.clinics.isEmpty
                                    ? const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(child: Text("No clinics verified in this zone yet.")),
                                )
                                    : SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                        final doc = state.clinics[index];
                                        return _buildClinicCard(doc.data()!, glassColor, borderColor, textColor, bgColor, isDark);
                                      },
                                      childCount: state.clinics.length,
                                    ),
                                  ),
                                ),
                            const SliverToBoxAdapter(child: SizedBox(height: 40)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildFrostedCircle(IconData icon, Color glassColor, Color borderColor, Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: glassColor, shape: BoxShape.circle, border: Border.all(color: borderColor)),
          child: Icon(icon, color: textColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> data, Color glassColor, Color borderColor, Color textColor, Color bgColor, bool isDark) {
    final cardColor = isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02);
    final name = data['name'] ?? 'Clinic';
    final ph = data['phone'] ?? 'N/A';
    final address = data['address'] ?? 'N/A';
    final fee = data['fee'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Icon(CupertinoIcons.heart_fill, color: Colors.blueAccent, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.outfit(color: textColor, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(CupertinoIcons.phone_fill, color: Colors.grey.shade500, size: 16),
                        SizedBox(width: 4),
                        Text(ph, style: TextStyle(color: Colors.grey.shade500)),
                        const Spacer(),
                        Text(fee + " INR", style: TextStyle(color: Colors.grey.shade500)),
                      ],
                      ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                        SizedBox(width: 6),
                        Text(address, style: TextStyle(color: Colors.grey.shade500)),
                      ]
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(100)),
                child: Text("Book Appointment", style: GoogleFonts.inter(color: bgColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(100)),
                child: Text("Directions", style: GoogleFonts.inter(color: bgColor, fontWeight: FontWeight.bold, fontSize: 13)),
              )
            ],
          )
        ],
      ),
    );
  }
}