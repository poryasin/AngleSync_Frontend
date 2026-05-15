import 'package:flutter/material.dart';

class AnalysisDetails extends StatelessWidget {
  const AnalysisDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("AI Coaching Feedback",
            style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Text("Form Summary: Your squat form is generally good..."),

        SizedBox(height: 10),

        Text("Injury Risk: Slight risk on right knee..."),

        SizedBox(height: 10),

        Text("Corrective Cues: Keep knees aligned..."),
      ],
    );
  }
}