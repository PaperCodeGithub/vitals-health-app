import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VFIconTextField extends StatelessWidget{
  final String text;
  final IconData icon;
  final double iconSize;
  final double fontSize;

  const VFIconTextField ({
    super.key,
    required this.text,
    required this.icon,
    this.iconSize = 40.0,
    this.fontSize = 30.0,
  });

  @override
  Widget build(BuildContext context){
    return Wrap(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.cause(
              fontSize: fontSize,
              fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}


class VBIconTextField extends StatelessWidget{
  final String text;
  final IconData icon;
  final double iconSize;
  final double fontSize;

  const VBIconTextField ({
    super.key,
    required this.text,
    required this.icon,
    this.iconSize = 40.0,
    this.fontSize = 30.0,
  });

  @override
  Widget build(BuildContext context){
    return Wrap(
      children: [
        Wrap(
          children: [
            Text(
              text,
              style: GoogleFonts.cause(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(width: 10),
            Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }
}

