import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitals/widgets/VButton.dart';
import 'package:vitals/widgets/VIconTextField.dart';
import 'package:vitals/widgets/VInputField.dart';
import 'package:vitals/widgets/errors/ShowError.dart';

class PasswordLessSignIn extends StatefulWidget {
  const PasswordLessSignIn({super.key});

  @override
  State<PasswordLessSignIn> createState() => _PasswordLessSignInState();
}

class _PasswordLessSignInState extends State<PasswordLessSignIn> {

  TextEditingController _email = TextEditingController();

  bool isEmail = false;

  void _continueOnEmail(BuildContext context){
    if(_email.text.isEmpty){
      showErrorSnackBar(context, "Please enter your email");
      return;
    }
    setState(() {
      isEmail = true;
    });
  }

  @override
  void dispose(){
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot password")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                if (!isEmail) ...[
                  VFIconTextField(
                      text: "Enter your email",
                      icon: Icons.email,
                      iconSize: 0,
                  ),
                  const SizedBox(height: 25),
                  VInputField(
                    controller: _email,
                    label: "Email",
                    icon: Icons.email,
                    accent: Colors.blue,
                  ),
                  const SizedBox(height: 25),
                  VButton(
                      text: "CONTINUE",
                      onPressed: (){
                        _continueOnEmail(context);
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white
                  )
                ] else ...[
                  VFIconTextField(
                    text: "We've sent an link to your email address",
                    icon: Icons.email,
                    iconSize: 0,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 25),
                  VButton(
                      text: "Login",
                      onPressed: (){},
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white
                  )
                ]
              ]
          )
        ),
      )
    );
  }

}