
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VInputField extends StatelessWidget{

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accent;
  final bool isPassword;

  const VInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accent,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context){
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),

        filled: true,
        fillColor: Colors.blue.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}