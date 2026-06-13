import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitals/auth/LoginScreen.dart';

class WelcomeScreen extends StatefulWidget{
  const WelcomeScreen({super.key});

  State<WelcomeScreen> createState() => _WelcomeScreenState();

}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('lib/assets/welcome_page_bg.jpg',
                fit: BoxFit.cover,
              )
          ),

          Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF121212).withOpacity(0.8),
                      const Color(0xFF121212),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  )
                ),
              )
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    "Your Health, Our Priority.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      height: 1.1, // Line height
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Connect with top clinics or manage your patient profile all in one place.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    )
                  ),

                  const SizedBox(height: 16),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}