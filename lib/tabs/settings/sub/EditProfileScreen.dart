import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vitals/widgets/VInputField.dart';

import '../../../location/LocationPickerScreen.dart';
import '../../../services/apis.dart';
import '../../../widgets/VButton.dart';
import '../../../widgets/VDropDownList.dart';
import '../../../widgets/errors/ShowError.dart';

class EditProfileScreen extends StatefulWidget {
  final String? accountType;
  const EditProfileScreen({super.key, required this.accountType});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

}

class _EditProfileScreenState extends State<EditProfileScreen>{

  bool _isEmergency = false;

  TextEditingController _nameController = TextEditingController();

  TextEditingController _ageController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _bloodGroupController = TextEditingController();

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _licenseController = TextEditingController();
  TextEditingController _hoursController = TextEditingController();
  TextEditingController _feeController = TextEditingController();

  String? _selectedGender = "Male";
  String? _selectedBloodGroup = "None";
  final List<String> _genders = ['Male', 'Female', 'Non-Binary', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'None'];


  String? _clinicAddress;
  double? _clinicLat;
  double? _clinicLng;

  bool _isFetching = true;
  bool _isSaving = false;

  bool _isLoadingGPS = false;

  @override
  void dispose(){
    super.dispose();
    _nameController.dispose();
    _hoursController.dispose();
    _feeController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodGroupController.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(widget.accountType == 'clinic')
      _getClinicDetails();
    else
      _getPatientProfile();
  }

  void _getClinicDetails() async {
    try{
      final DocumentSnapshot snapshot = await DatabaseService.instance.getProfile();
      if(snapshot.exists){
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _clinicAddress = data['address'];
          _clinicLat = data['lat'];
          _clinicLng = data['lng'];

          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _licenseController.text = data['license'] ?? '';
          _hoursController.text = data['hours'] ?? '';

          _feeController.text = data['fee']?.toString() ?? '';

          _isEmergency = data['emergency'] ?? false;

        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }finally{
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  void _updateClinicProfile() async {
    try{

      if(_clinicAddress == null || _nameController.text.isEmpty || _phoneController.text.isEmpty || _licenseController.text.isEmpty || _clinicLat == null || _clinicLng == null){
        showErrorSnackBar(context, "Please fill in Necessary fields. (Name, Phone, License, Location)");
        return;
      }

      setState(() {
        _isSaving = true;
      });

      FocusScope.of(context).unfocus();

      await DatabaseService.instance.updateClinicProfile(
        name: _nameController.text,
        lat: _clinicLat!,
        lng: _clinicLng!,
        address: _clinicAddress!,
        phone: _phoneController.text,
        license: _licenseController.text,
        hours: _hoursController.text.isEmpty ? "" : _hoursController.text,
        fee: _feeController.text.isEmpty ? "" : _feeController.text,
        emergency: _isEmergency,
      );

      if(mounted){
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        _isSaving = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _updatePatientProfile() async {
    try {
      if (_nameController.text.isEmpty ||
          _ageController.text.isEmpty ||
          _selectedGender == null) {
        showErrorSnackBar(context, "Please fill in all fields.");
        return;
      }
      setState(() {
        _isSaving = true;
      });

      await DatabaseService.instance.updatePatientProfile(
        name: _nameController.text,
        age: _ageController.text,
        gender: _selectedGender!,
        height: _heightController.text,
        weight: _weightController.text,
        bloodGroup: _selectedBloodGroup!,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        _isSaving = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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

      Position pos = await DatabaseService.instance.determineLocation();
      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LocationPickerScreen(
                  initialLat: pos.latitude, initialLng: pos.longitude),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
        _isLoadingGPS = false;
      }
    } finally {
      if(mounted) setState(() => _isLoadingGPS = false);
    }
  }

  void _getPatientProfile() async {
    try{
      setState(() {
        _isFetching = true;
      });

      final DocumentSnapshot snapshot = await DatabaseService.instance.getProfile();
      if(snapshot.exists){
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _ageController.text = data['age'] ?? '';
          _selectedGender = data['gender'] ?? '';
          _heightController.text = data['height'] ?? '';
          _weightController.text = data['weight'] ?? '';
          if(data['bloodGroup'].toString().isNotEmpty) _selectedBloodGroup = data['bloodGroup'];
        });
      }

    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }finally{
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: SafeArea(
        child: _isFetching
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Center(
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage('https://your-image-url.com/profile.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),

                  _buildSectionHeader("Personal"),

                  SizedBox(height: 10),

                  VInputField(
                    label: widget.accountType == "clinic" ? "Clinic Name" : "Name",
                    icon: Icons.account_circle_outlined,
                    accent: Colors.blue,
                    controller: _nameController,
                  ),

                  if(widget.accountType == "clinic") ...[
                    const SizedBox(height: 20),
                    VInputField(
                      label: "Phone number",
                      icon: Icons.phone,
                      accent: Colors.blue,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 20),
                    VInputField(
                      label: "License number",
                      icon: Icons.numbers,
                      accent: Colors.blue,
                      controller: _licenseController,
                    ),

                    SizedBox(height: 40),

                    _buildSectionHeader("Operations"),

                    const SizedBox(height: 10),

                    VInputField(
                        label: "Operating Hours (e.g. 9AM - 8PM)",
                        icon: Icons.access_time,
                        accent: Colors.blue,
                        controller: _hoursController
                    ),
                    const SizedBox(height: 20),
                    VInputField(label: "Base Consultation Fee (₹)", icon: Icons.payments, accent: Colors.blue, controller: _feeController),
                    const SizedBox(height: 40),
                    SwitchListTile(
                      title: const Text("24/7 Emergency Service", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Keep on if you accept late-night emergencies."),
                      value: _isEmergency,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() => _isEmergency = value);
                      },
                    ),
                    const SizedBox(height: 40),

                    _buildSectionHeader("Location"),
                    const SizedBox(height: 20),

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
                              child: Text(_clinicAddress!, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            ),
                          ],
                        ),
                      ),

                    _isLoadingGPS
                    ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                    : VButton(
                      text: _clinicAddress == null ? "Set Location on Map" : "Update Location on Map",
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      onPressed: () => _getLocation(),
                    ),
                  ] else ... [
                    const SizedBox(height: 20),
                    VInputField(
                      label: "Age",
                      icon: Icons.calendar_month,
                      accent: Colors.blue,
                      controller: _ageController,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        Expanded(
                          child: VDropDownList(
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
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: VInputField(
                            label: "Height (cm)",
                            icon: Icons.height,
                            accent: Colors.blue,
                            controller: _heightController,
                          ),
                        )
                      ]
                    ),
                    const SizedBox(height: 26),
                    VInputField(
                      label: "Weight (kg)",
                      icon: Icons.monitor_weight,
                      accent: Colors.blue,
                      controller: _weightController,
                    ),
                    const SizedBox(height: 26),
                    VDropDownList(
                      label: "Blood Group",
                      icon: Icons.bloodtype,
                      items: _bloodGroups,
                      value: _selectedBloodGroup,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBloodGroup = newValue;
                        });
                      },
                    ),
                  ],
                  SizedBox(height: 50),
                  IgnorePointer(
                    ignoring: _isSaving,
                    child: VButton(
                      text: _isSaving ? "SAVING..." : "SAVE CHANGES",
                      backgroundColor: _isSaving ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        if(widget.accountType == 'patient'){
                          _updatePatientProfile();
                        } else {
                          _updateClinicProfile();
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

}