import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vitals/location/LocationPickerScreen.dart';
import 'package:vitals/main.dart';
import 'package:vitals/services/apis.dart';
import 'package:vitals/widgets/VButton.dart';
import 'package:vitals/widgets/VDropDownList.dart';
import 'package:vitals/widgets/VIconTextField.dart';
import 'package:vitals/widgets/VInputField.dart';
import 'package:vitals/widgets/errors/ShowError.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  bool? isPatient;

  double? _clinicLat;
  double? _clinicLng;
  String? _clinicAddress;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _clinic_ph_number = TextEditingController();
  final TextEditingController _clinic_license_number = TextEditingController();

  String? _selectedGender = "Male";
  final List<String> _genders = ['Male', 'Female', 'Non-Binary', 'Other'];

  bool isLoading = false;
  bool _isLoadingGPS = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isPatient == null ? _buildSelectionView() : _buildFormView(),
      ),
    );
  }

  void _createPatientProfile() async {
    try{
      setState(() {
        isLoading = true;
      });

      if(_nameController.text.isEmpty || _ageController.text.isEmpty || _selectedGender == null){
        showErrorSnackBar(context, "Please fill in all fields.");
        return;
      }

      await DatabaseService.instance.createPatientProfile(
        name: _nameController.text,
        age: _ageController.text,
        gender: _selectedGender!,
        height: '',
        weight: '',
        bloodGroup: '',
      );

      if(mounted){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
              (route) => false,
        );
      }

    } catch (e) {
      showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _createClinicProfile() async {

    if(_clinicAddress == null || _nameController.text.isEmpty || _clinic_ph_number.text.isEmpty || _clinic_license_number.text.isEmpty || _clinicLat == null || _clinicLng == null){
      showErrorSnackBar(context, "Please fill in all fields.");
      return;
    }


    try{
      setState(() {
        isLoading = true;
      });

      await DatabaseService.instance.createClinicProfile(
        name: _nameController.text,
        lat: _clinicLat!,
        lng: _clinicLng!,
        address: _clinicAddress!,
        phone: _clinic_ph_number.text,
        license: _clinic_license_number.text,
        hours: "",
        fee: "",
        emergency: false,
      );

      if(mounted){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
              (route) => false,
        );
      }

    } catch (e) {
      showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isPatient = null;
        });
      }
    }
  }

  void _getLocation() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Fetching GPS..."), duration: Duration(seconds: 1)),
      );

      setState(() {
        _isLoadingGPS = true;
      });

      Position pos = await DatabaseService.instance
          .determineLocation();

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LocationPickerScreen(
                initialLat: pos.latitude,
                initialLng: pos.longitude,
              ),
        ),
      );

      if (result != null && mounted) {
        setState(() {
          _clinicLat = result['lat'];
          _clinicLng = result['lng'];
          _clinicAddress = result['address'];
          _isLoadingGPS = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e.toString());
        print(e.toString());

        setState(() {
          _isLoadingGPS = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGPS = false;
        });
      }
    }
  }

  Widget _buildSelectionView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            "Select Account Type",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Are you joining as a patient or setting up a clinic?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 50),
          VButton(
            text: "I AM A PATIENT",
            onPressed: () {
              setState(() {
                isPatient = true;
              });
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 20),
          VButton(
            text: "I HAVE A CLINIC",
            onPressed: () {
              setState(() {
                isPatient = false;
              });
            },
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            foregroundColor: Theme.of(context).colorScheme.surface,
          ),
        ],
      ),
    );
  }


  Widget _buildFormView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              alignment: Alignment.centerLeft,
              onPressed: () {
                setState(() {
                  isPatient = null;
                });
              },
            ),
            const SizedBox(height: 10),
            VFIconTextField(
              text: isPatient! ? "Create Patient Profile" : "Create Clinic Profile",
              icon: isPatient! ? Icons.person : Icons.house,
            ),
            const SizedBox(height: 30),
            VInputField(
              label: isPatient! ? "Full Name" : "Clinic Name",
              icon: isPatient! ? Icons.account_circle_outlined : Icons.local_hospital,
              accent: Colors.blue,
              controller: _nameController,
            ),
            const SizedBox(height: 26),

            if (isPatient!) ...[
              VInputField(
                label: "Age",
                icon: Icons.calendar_month,
                accent: Colors.blue,
                controller: _ageController,
              ),
              const SizedBox(height: 26),
              VDropDownList(
                label: "Gender",
                icon: Icons.male,
                items: _genders,
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
            ]
            else ...[
              if (_clinicAddress != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _clinicAddress!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              _isLoadingGPS
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue))
              :
              VButton(
                text: _clinicAddress == null ? "Get Location" : "Change Location",
                onPressed: () => _getLocation(),
                foregroundColor: Theme.of(context).colorScheme.surface,
                backgroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 20),
              VInputField(
                label: "Phone number",
                icon: Icons.phone,
                accent: Colors.blue,
                controller: _clinic_ph_number,
              ),
              const SizedBox(height: 20),
              VInputField(
                label: "License number",
                icon: Icons.numbers,
                accent: Colors.blue,
                controller: _clinic_license_number,
              )
            ],
            const SizedBox(height: 50),
            isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
                : VButton(
              text: "CONTINUE",
              onPressed: () {
                if (isPatient!) {
                  _createPatientProfile();
                } else {
                  _createClinicProfile();
                }
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}