import 'package:connectcare/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  List<dynamic> _feedbacks = [];
  bool _isLoading = true;

  Future<void> _fetchFeedbacks() async {
    final url = Uri.parse('$baseUrl/feedback');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _feedbacks = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load feedbacks.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading feedbacks'.tr())),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedbacks'.tr()),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = _feedbacks[index];
                return ListTile(
                  title: Text(feedback['comentario']),
                  subtitle: Text(
                      '${feedback['nombre_usuario']} (${feedback['tipo_usuario']}) - ${feedback['fecha']}'),
                );
              },
            ),
    );
  }
}
