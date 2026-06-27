import '../enums/subject_type.dart';
import '../models/subject.dart';

class SubjectRepository {
  const SubjectRepository();

  List<Subject> getSubjects() {
    return const [
      Subject(
        type: SubjectType.mobileAppDevelopment,
        name: 'Mobile App Development',
        description:
            'Covers mobile UI design, Flutter widgets, navigation, state handling, forms, validation, and deployment basics for modern mobile applications.',
        timing: 'Monday and Wednesday, 10:00 AM - 11:30 AM',
        schedule:
            'Weekly lab sessions focus on building multi-screen Flutter apps, reusable components, and project-based assignments.',
        bannerIcon: 'MAD',
      ),
      Subject(
        type: SubjectType.softwareReEngineering,
        name: 'Software Re-engineering',
        description:
            'Introduces techniques for analyzing, restructuring, documenting, and improving existing software systems while preserving their behavior.',
        timing: 'Tuesday and Thursday, 12:00 PM - 1:30 PM',
        schedule:
            'Students review legacy code, identify improvement areas, and practice refactoring with maintainability goals.',
        bannerIcon: 'SRE',
      ),
      Subject(
        type: SubjectType.managementInformationSystems,
        name: 'Management Information Systems (MIS)',
        description:
            'Explores how information systems support business decisions, reporting, operations, and strategic planning in organizations.',
        timing: 'Friday, 9:00 AM - 12:00 PM',
        schedule:
            'Classes combine lectures, case studies, and system analysis activities focused on business information flow.',
        bannerIcon: 'MIS',
      ),
    ];
  }
}
