import 'package:flutter/material.dart';
import '../../../../core/widgets/app_tool_card.dart';

class FeatureCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final List<String> capabilityLabels;
  final VoidCallback onPressed;

  const FeatureCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.capabilityLabels,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => AppToolCard(
    icon: icon,
    title: title,
    description: description,
    actionLabel: actionLabel,
    capabilityLabels: capabilityLabels,
    onPressed: onPressed,
  );
}
