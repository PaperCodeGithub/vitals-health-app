import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const LocationPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  late LatLng _centerPosition;

  String _currentAddress = "Move the map to set location";
  bool _isDragging = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _centerPosition = LatLng(widget.initialLat, widget.initialLng);
    _getAddressFromLatLng(_centerPosition);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _searchAddress() async {
    if (_searchController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() => _isSearching = true);

    try {
      List<Location> locations = await locationFromAddress(_searchController.text);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPosition, zoom: 16.0),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not find that address.")),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Clinic Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _centerPosition,
              zoom: 16.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            padding: const EdgeInsets.only(top: 80.0, bottom: 220.0),
            onCameraMove: (CameraPosition position) {
              setState(() {
                _isDragging = true;
                _centerPosition = position.target;
              });
            },

            onCameraIdle: () {
              setState(() {
                _isDragging = false;
              });
              _getAddressFromLatLng(_centerPosition);
            },

            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchAddress(),
                  decoration: InputDecoration(
                    hintText: "Search street or area...",
                    border: InputBorder.none,
                    icon: _isSearching
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)
                    )
                        : const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Icon(
                Icons.location_on,
                size: 50,
                color: _isDragging ? Colors.black54 : Colors.blue,
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Clinic is in",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isDragging ? "Locating..." : _currentAddress,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15)
                        ),
                        onPressed: _isDragging
                            ? null
                            : () {
                          Navigator.pop(context, {
                            'lat': _centerPosition.latitude,
                            'lng': _centerPosition.longitude,
                            'address': _currentAddress,
                          });
                        },
                        child: const Text("CONFIRM LOCATION", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}