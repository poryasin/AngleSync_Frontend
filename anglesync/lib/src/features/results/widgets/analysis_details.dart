import 'package:flutter/material.dart';

class AnalysisDetails extends StatefulWidget {
  const AnalysisDetails({super.key});

  @override
  State<AnalysisDetails> createState() => _AnalysisDetailsState();
}

class _AnalysisDetailsState extends State<AnalysisDetails> {
  bool _cuesExpanded = false;
  bool _planExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ──
        const Text(
          "DETAILED REPORT",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF667085),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        // ── AI Coach card ──
        _buildCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI COACH",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Coaching Feedback",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "SQUAT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF444444),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Form + Injury Risk card ──
        _buildCard(
          child: Column(
            children: [
              // Form row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.assignment_outlined,
                        color: Colors.green, size: 17),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FORM",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667085),
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Good form overall",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 6),
                        _FixItem(
                          icon: Icons.arrow_forward_ios_rounded,
                          text: "Right shoulder slightly forward",
                        ),
                        SizedBox(height: 4),
                        _FixItem(
                          icon: Icons.arrow_forward_ios_rounded,
                          text: "Right elbow flaring out",
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Color(0xFFF0F0F0), height: 1),
              ),

              // Injury Risk row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: Color(0xFFE53935), size: 17),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "INJURY RISK",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667085),
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Focus on Right Knee",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const _FixItem(
                          icon: Icons.arrow_forward_ios_rounded,
                          text: "Highest risk at t=3.8–4.8s",
                          isRisk: true,
                        ),
                        const SizedBox(height: 4),
                        const _FixItem(
                          icon: Icons.arrow_forward_ios_rounded,
                          text: "Avg error 22.0° — needs correction",
                          isRisk: true,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: const [
                            _RiskTag(label: "Right Knee", isHighlight: true),
                            _RiskTag(label: "Left Hip"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Corrective Cues accordion ──
        _buildAccordion(
          icon: Icons.track_changes_outlined,
          title: "Corrective cues",
          subtitle: "6 actionable tips",
          isExpanded: _cuesExpanded,
          onTap: () => setState(() => _cuesExpanded = !_cuesExpanded),
          expandedContent: const _CorrectiveCuesContent(),
        ),
        const SizedBox(height: 10),

        // ── Practice Plan accordion ──
        _buildAccordion(
          icon: Icons.calendar_today_outlined,
          title: "Practice plan",
          subtitle: "Warm-up · Main · Cooldown",
          isExpanded: _planExpanded,
          onTap: () => setState(() => _planExpanded = !_planExpanded),
          expandedContent: const _PracticePlanContent(),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAccordion({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget expandedContent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF667085),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding:
                  const EdgeInsets.only(left: 18, right: 18, bottom: 18),
              child: Column(
                children: [
                  const Divider(color: Color(0xFFF0F0F0), height: 1),
                  const SizedBox(height: 14),
                  expandedContent,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Fix Item ──
class _FixItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isRisk;

  const _FixItem({
    required this.text,
    required this.icon,
    this.isRisk = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(
            icon,
            size: 10,
            color: isRisk ? const Color(0xFFE53935) : Colors.green,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isRisk
                  ? const Color(0xFFE53935)
                  : const Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Risk Tag ──
class _RiskTag extends StatelessWidget {
  final String label;
  final bool isHighlight;

  const _RiskTag({
    required this.label,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFFFECEC)
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isHighlight
              ? const Color(0xFFE53935)
              : const Color(0xFF444444),
        ),
      ),
    );
  }
}

// ── Corrective Cues Content ──
class _CorrectiveCuesContent extends StatelessWidget {
  const _CorrectiveCuesContent();

  @override
  Widget build(BuildContext context) {
    final cues = [
      "Keep knees aligned with toes",
      "Engage core before descending",
      "Drive through heels on the way up",
      "Chest tall, spine neutral",
      "Control the descent — don't drop fast",
      "Pause briefly at the bottom",
    ];
    return Column(
      children: cues.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${e.key + 1}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Practice Plan Content ──
class _PracticePlanContent extends StatelessWidget {
  const _PracticePlanContent();

  @override
  Widget build(BuildContext context) {
    final phases = [
      {
        "phase": "Warm-up",
        "duration": "5 min",
        "items": ["Leg swings × 10", "Hip circles × 10", "BW squat × 15"],
      },
      {
        "phase": "Main",
        "duration": "20 min",
        "items": ["3 × 10 goblet squat", "3 × 8 pause squat", "2 × 12 split squat"],
      },
      {
        "phase": "Cooldown",
        "duration": "5 min",
        "items": ["Hip flexor 30s", "Quad stretch 30s", "Pigeon pose 60s"],
      },
    ];

    return Column(
      children: phases.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p["phase"] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      p["duration"] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (p["items"] as List<String>)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            "· $item",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF444444),
                              height: 1.4,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}