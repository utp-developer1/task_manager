enum UserRole { superior, subordinate }

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? profileImage;
  final int tasksCompleted;
  final double totalHoursLogged;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.profileImage,
    this.tasksCompleted = 0,
    this.totalHoursLogged = 0.0,
  });
}
