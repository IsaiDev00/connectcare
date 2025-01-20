import 'package:flutter/material.dart';

class CustomButton2 extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButton2({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[50],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Color(0xFF00A0A6)),
        label: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
