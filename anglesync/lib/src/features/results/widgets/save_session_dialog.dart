import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

/// Pop-up dialog for entering a Session Name when saving an analysis result.
/// SRS-014: if left blank, auto-assigns a default name (Session_YYYYMMDD_HHMMSS).
class SaveSessionDialog extends StatelessWidget {
  const SaveSessionDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SaveSessionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Save Session'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Session Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
          onPressed: () {
            final input = controller.text.trim();
            final finalName = input.isNotEmpty
                ? input
                : 'Session_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';
            Navigator.pop(context, finalName);
          },
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}