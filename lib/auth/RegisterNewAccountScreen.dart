
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitals/auth/CreateProfile.dart';
import 'package:vitals/widgets/VButton.dart';
import 'package:vitals/widgets/VIconTextField.dart';
import 'package:vitals/widgets/VInputField.dart';
import 'package:vitals/widgets/errors/ShowError.dart';

class RegisterNewAccountScreen extends StatefulWidget{
  const RegisterNewAccountScreen({super.key});

  State<RegisterNewAccountScreen> createState() => _RegisterNewAccountScreenState();
}

class _RegisterNewAccountScreenState extends State<RegisterNewAccountScreen>{

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _isloading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      showErrorSnackBar(context, "Please fill in all fields.");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showErrorSnackBar(context, "Passwords do not match.");
      return;
    }

    setState(() {
      _isloading = true;
    });

    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if(mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CreateProfile()),
              (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorSnackBar(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showErrorSnackBar(context, 'The account already exists for that email.');
      } else {
        showErrorSnackBar(context, 'An error occurred: ${e.message}');
      }
    } catch (e) {
      showErrorSnackBar(context, 'An unexpected error occurred.');
    }finally{
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                VFIconTextField(
                  text: "Let's Get Started",
                  icon: Icons.create,
                  iconSize: 35,
                ),
                const SizedBox(height: 50),
                VInputField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email,
                    accent: Colors.blue,
                ),
                const SizedBox(height: 26),
                VInputField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  accent: Colors.blue,
                ),
                const SizedBox(height: 26),
                VInputField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_open,
                  accent: Colors.blue,
                ),
                const SizedBox(height: 50),
                VButton(
                  text: _isloading ? "Wait a moment..." : "CONTINUE",
                  onPressed: _register,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white
                ),
                const SizedBox(height: 25),
                VButton(
                    text: "BACK",
                    onPressed: (){Navigator.pop(context);},
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white
                ),
              ],
            )
          )
        )
      ),
    );
  }
}
