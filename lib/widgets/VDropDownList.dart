import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VDropDownList extends StatelessWidget{
  final String label;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final Color accent;

  const VDropDownList({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.accent = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      menuMaxHeight: 250,
      style: GoogleFonts.cause(
        color: Colors.blue,
        fontWeight: FontWeight.bold
      ),
      icon: Icon(Icons.arrow_drop_down, color: accent),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
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