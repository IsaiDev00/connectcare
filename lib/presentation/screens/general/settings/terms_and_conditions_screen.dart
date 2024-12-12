import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  TermsAndConditionsScreenState createState() =>
      TermsAndConditionsScreenState();
}

class TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String _termsAndConditions = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTermsAndConditions();
  }

  Future<void> _fetchTermsAndConditions() async {
    final url = '$baseUrl/documents/terms';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _termsAndConditions = data['content'];
          _loading = false;
        });
      } else {
        setState(() {
          _termsAndConditions = 'Error loading Terms and Conditions'.tr();
          _loading = false;
        });
      }
    } catch (error) {
      setState(() {
        _termsAndConditions = 'Connection error: Could not load content.'.tr();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'.tr()),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _termsAndConditions,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
    );
  }
}
