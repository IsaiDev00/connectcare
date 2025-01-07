import 'package:connectcare/core/constants/constants.dart';
import 'package:connectcare/data/services/user_service.dart';
import 'package:connectcare/presentation/widgets/snack_bar.dart';
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
  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      Intl.defaultLocale = context.locale.toString();
      return DateFormat.yMMMMd(Intl.defaultLocale).add_jm().format(parsedDate);
    } catch (e) {
      return 'Invalid date'.tr();
    }
  }

  List<dynamic> _feedbacks = [];
  bool _isLoading = true;
  String? _clues;

  @override
  void initState() {
    super.initState();
    _fetchUserClues().then((_) => _fetchFeedbacks());
  }

  Future<void> _fetchUserClues() async {
    try {
      final userData = await UserService().loadUserData();
      setState(() {
        _clues = (userData['clues'] ?? '');
      });
    } catch (e) {
      _userErrorResponse();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFeedbacks() async {
    if (_clues == null) return;

    final url = Uri.parse('$baseUrl/feedback?clues=$_clues');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _feedbacks = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load feedbacks.'.tr());
      }
    } catch (e) {
      _errorLoadingFeedbacks();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFeedback(int feedbackId) async {
    final url = Uri.parse('$baseUrl/feedback/$feedbackId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          _feedbacks
              .removeWhere((feedback) => feedback['id_feedback'] == feedbackId);
        });
        _feedbackDeletedSuccessfully();
      } else {
        throw Exception('Failed to delete feedback.'.tr());
      }
    } catch (e) {
      _errorDeletingFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;

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
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      feedback['tipo_usuario'] == 'personal'
                          ? Icons.person
                          : Icons.group,
                      color: colorScheme.primary,
                    ),
                    title: Text(feedback['comentario'] ?? 'No comment'.tr()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feedback_user'.tr(args: [
                            feedback['nombre_usuario'] ?? 'Unknown'.tr(),
                            translateUserType(feedback['tipo_usuario'])
                          ]),
                        ),
                        Text(
                            'Destination: ${translateDestination(feedback['destino'])}'),
                        Text('Feedback_date'
                            .tr(args: [formatDate(feedback['fecha'])])),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () => _deleteFeedback(feedback['id_feedback']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String translateUserType(String userType) {
    switch (userType) {
      case 'personal':
        return 'Personal'.tr();
      case 'familiar':
        return 'Family'.tr();
      default:
        return 'Unknown'.tr();
    }
  }

  String translateDestination(String destination) {
    switch (destination) {
      case 'developers':
        return 'Developers'.tr();
      case 'administrators':
        return 'Administrators'.tr();
      default:
        return 'Unknown'.tr();
    }
  }

  void _errorLoadingFeedbacks() {
    showCustomSnackBar(context, 'Error loading feedbacks'.tr());
  }

  void _userErrorResponse() {
    showCustomSnackBar(context, 'Error loading user data'.tr());
  }

  void _feedbackDeletedSuccessfully() {
    showCustomSnackBar(context, 'Feedback deleted successfully'.tr());
  }

  void _errorDeletingFeedback() {
    showCustomSnackBar(context, 'Error deleting feedback'.tr());
  }
}
