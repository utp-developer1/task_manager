class ActivityLog {
  final String id;
  final String userId;
  final String description; // e.g. "Changed status to Done"
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.description,
    required this.timestamp,
  });
}
