import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? userId = '';
  String userType = '';
  String clues = '';
  bool isStaff = false;
  String selectedDestination = 'administrators';
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService().loadUserData();
      setState(() {
        userId = (userData['userId'] ?? '');
        userType = (userData['userType'] ?? '');
        clues = (userData['clues'] ?? '');
        isStaff = [
          'stretcher bearer',
          'doctor',
          'nurse',
          'social worker',
          'human resources',
          'administrator'
        ].contains(userType);
      });
    } catch (e) {
      _userErrorResponse();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFeedback() async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write a comment'.tr())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseUrl/feedback');
    final body = jsonEncode({
      'id_familiar': isStaff == false ? userId : null,
      'id_personal': isStaff == true ? userId : null,
      'comentario': _feedbackController.text.trim(),
      'clues': clues.isEmpty ? null : clues,
      'destino': selectedDestination,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        _thanksForFeedback();
        _feedbackController.clear();
        setState(() {
          selectedDestination = 'administrators';
        });
      } else {
        throw Exception('Failed to send feedback.');
      }
    } catch (e) {
      _errorSendingFeedback();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildDestinationSelection(context),
            const SizedBox(height: 16),
            _buildCommentInput(context),
            const SizedBox(height: 20),
            _buildSendButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationSelection(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Who is your feedback for?'.tr(),
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDestinationCard(
              context,
              'administrators',
              Icons.admin_panel_settings,
              'Administration',
              'For feedback about administration.'.tr(),
            ),
            const SizedBox(width: 8),
            _buildDestinationCard(
              context,
              'developers',
              Icons.developer_mode,
              'Developers',
              'For feedback about app functionality.'.tr(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDestinationCard(BuildContext context, String value,
      IconData icon, String title, String description) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDestination = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: selectedDestination == value
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selectedDestination == value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                color: selectedDestination == value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return TextField(
      controller: _feedbackController,
      maxLines: 6,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(),
      decoration: InputDecoration(
        hintText: 'Write your comments here...'.tr(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: _isLoading ? null : _sendFeedback,
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                'Send'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
      ),
    );
  }

  void _userErrorResponse() {
    showCustomSnackBar(context, 'Error loading user data'.tr());
  }

  void _thanksForFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thanks for your comment'.tr())),
    );
  }

  void _errorSendingFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sending feedback'.tr())),
    );
  }
}
