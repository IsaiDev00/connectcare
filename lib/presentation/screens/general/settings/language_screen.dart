import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Language'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            title: Text('Español'),
            onTap: () {
              context.setLocale(Locale('es'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Idioma cambiado a Español'),
                    duration: Duration(seconds: 1)),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            title: Text('English'),
            onTap: () {
              context.setLocale(Locale('en'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Language changed to English'),
                    duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
    );
  }
}
