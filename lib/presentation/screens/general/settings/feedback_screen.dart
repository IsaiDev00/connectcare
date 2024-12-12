import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints and Suggestions'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please share your complaints or suggestions to improve our service.'
                  .tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Write your comments here...'.tr(),
                hintStyle: theme.textTheme.headlineSmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thanks for your comment'.tr())),
                );
              },
              child: Text('Send'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
