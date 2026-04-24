import 'package:flutter/material.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: 'en',
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'es', child: Text('Español')),
      ],
      onChanged: (val) {
        // change locale
      },
    );
  }
}
