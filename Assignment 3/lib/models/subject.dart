import '../enums/subject_type.dart';

class Subject {
  const Subject({
    required this.type,
    required this.name,
    required this.description,
    required this.timing,
    required this.schedule,
    required this.bannerIcon,
  });

  final SubjectType type;
  final String name;
  final String description;
  final String timing;
  final String schedule;
  final String bannerIcon;
}
