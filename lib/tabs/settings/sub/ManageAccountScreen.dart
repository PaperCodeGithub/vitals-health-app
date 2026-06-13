
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitals/welcome_screen.dart';
import 'package:vitals/services/apis.dart';
import 'package:vitals/widgets/VButton.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {

  bool _isLoading = false;

  void _logout() async {
    try{
      setState(() {
        _isLoading = true;
      });

      await DatabaseService.instance.signOut();

      if(mounted){
        setState(() {
          _isLoading = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
              (route) => false,
        );
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Account"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 26),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                VButton(
                  text: "Logout",
                  onPressed: _logout,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                )
              ],
            ),
          ),
        ),
      )
    );
  }

}