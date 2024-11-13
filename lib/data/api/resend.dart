import 'dart:convert';
import 'package:connectcare/core/constants/constants.dart';
import 'package:http/http.dart' as http;

class ResendService {
  final String url = '$baseUrl/email/send-email';

  Future<void> sendReportRequestEmail({
    required String rejectionReason,
    required String sender,
  }) async {
    final htmlContent = '''
      <h1>Your Hospital Admission Request on Connect Care Has Been Reviewed</h1>
      <p>Dear user</p>
      <p>We regret to inform you that your request to gain admission to our hospital has not been accepted at this time. Our administration carefully reviews each request to ensure the safety and well-being of all our patients and staff. Based on our review, we have decided to deny your entry request for the following reason:</p>
      
      <blockquote><p><strong>Reason:</strong> $rejectionReason</p></blockquote>

      <p>We understand that this may be disappointing, and we encourage you to reach out to us if you need further assistance or clarification.</p>
      <p>Thank you for your understanding and cooperation.</p>
      
      <p>Best regards,<br>
      Connect Care, Hospital</p>
    ''';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': sender,
          'subject': 'Connect Care - Admission Review',
          'body': htmlContent.toString(),
        }),
      );

      if (response.statusCode == 200) {
        // print('Email sent successfully!');
      } else {
        // print('Failed to send email: ${response.body.toString()}');
      }
    } catch (error) {
      // print('Error occurred: $error');
    }
  }
}
