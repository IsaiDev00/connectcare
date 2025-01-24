// services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Projection>> fetchProjections(String endpoint, Map<String, dynamic> params) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final projections = data['p'] as List<dynamic>;
      return projections.map((json) => Projection.fromJson(json)).toList();
    } else {
      throw Exception('Error: ${response.body}');
    }
  }
}
