import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  // required arguments
  final String label;
  final IconData icon;

  // optional arguments
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool obscureText;

  CustomTextFormField({required this.label, required this.icon, this.onSaved, this.validator, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: IconTheme(
          data: IconThemeData(
            color: Colors.black,
          ),
          child: Icon(icon),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
      obscureText: obscureText,
    );
  }
}
