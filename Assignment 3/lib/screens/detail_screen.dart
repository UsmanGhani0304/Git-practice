import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../widgets/subject_banner.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subject Detail')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              subject.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 18),
            SubjectBanner(label: subject.bannerIcon),
            const SizedBox(height: 24),
            _DetailSection(
              title: 'Description',
              child: Text(subject.description),
            ),
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Class Timing',
              child: Text(subject.timing),
            ),
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Schedule Information',
              child: Text(subject.schedule),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodyLarge,
          child: child,
        ),
      ],
    );
  }
}
