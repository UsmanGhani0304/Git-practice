import '../enums/gender.dart';

class AppUser {
  const AppUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;
  final String password;

  String get fullName => '$firstName $lastName';

  Map<String, String> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender.name,
      'password': password,
    };
  }

  factory AppUser.fromMap(Map<String, String> map) {
    return AppUser(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      gender: Gender.values.firstWhere(
        (gender) => gender.name == map['gender'],
        orElse: () => Gender.other,
      ),
      password: map['password'] ?? '',
    );
  }
}
