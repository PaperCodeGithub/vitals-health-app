import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vitals/auth/RegisterNewAccountScreen.dart';
import 'package:vitals/main.dart';
import 'package:vitals/widgets/VButton.dart';
import 'package:vitals/widgets/VInputField.dart';
import 'package:vitals/widgets/errors/ShowError.dart';

import 'PasswordlessSignin.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showErrorSnackBar(context, "Please fill in all fields.");
      return;
    }
    setState(() {
      isLoading = true;
    });

    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if(mounted){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showErrorSnackBar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showErrorSnackBar(context, 'Wrong password provided for that user.');
      } else {
        showErrorSnackBar(context, 'An error occurred: ${e.message}');
      }
    } catch (e) {
      showErrorSnackBar(context, 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()), // Update to your Dashboard screen
              (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message ?? "Authentication failed");
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "An error occurred: ${e.toString()}");
      print(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 40,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Welcome back",
                        style: GoogleFonts.cause(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
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
                    accent: Colors.transparent,
                    isPassword: true
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        forgotPassword(context);
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          isLoading ? "Logging in..." : "CONTINUE",
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900,
                              color: Colors.white
                          ),
                        )
                    ),
                  ),

                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        signInWithGoogle();
                      },
                      // The Font Awesome Google Icon!
                      icon: FaIcon(
                        FontAwesomeIcons.google,
                        color: Theme.of(context).colorScheme.surface,
                        size: 20,
                      ),
                      label: Text(
                        isLoading ? "Loading..." : "Continue with Google",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                  VButton(
                      text: "BACK",
                      onPressed: () => back(context),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white
                  ),

                  SizedBox(height: 25),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        register(context);
                      },
                      child: const Text(
                        "Create a new account",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }

  void back(BuildContext context){
    Navigator.pop(context);
  }

  void register(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterNewAccountScreen()),
    );
  }

  void forgotPassword(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordLessSignIn()));
  }
}