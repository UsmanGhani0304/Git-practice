import 'package:flutter/material.dart';

class SubjectBanner extends StatelessWidget {
  const SubjectBanner({
    super.key,
    required this.label,
    this.height = 180,
  });

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
      ),
    );
  }
}
