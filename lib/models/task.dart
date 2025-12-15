import 'package:flutter/material.dart';
import 'activity_log.dart';

enum TaskStatus { pending, inProgress, review, done }
enum TaskPriority { low, medium, high }
enum RecurrenceInterval { none, daily, weekly, monthly }

class Comment {
  final String id;
  final String authorId;
  final String content;
  final DateTime timestamp;

  Comment({required this.id, required this.authorId, required this.content, required this.timestamp});
}

class TimeEntry {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;

  TimeEntry({required this.id, required this.userId, required this.startTime, this.endTime});

  Duration get duration => endTime != null 
    ? endTime!.difference(startTime) 
    : DateTime.now().difference(startTime);
}

class Task {
  final String id;
  final String title;
  final String description;
  final String assigneeId;
  final String creatorId;
  final DateTime dueDate;
  TaskStatus status;
  TaskPriority priority;
  double progress;
  
  // New Features
  List<Comment> comments;
  List<TimeEntry> timeLogs;
  List<String> attachments; // File Paths
  RecurrenceInterval recurrence;
  double estimatedHours;
  List<ActivityLog> activityLogs;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.creatorId,
    required this.dueDate,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.progress = 0.0,
    this.comments = const [],
    this.timeLogs = const [],
    this.attachments = const [],
    this.recurrence = RecurrenceInterval.none,
    this.estimatedHours = 0.0,
    this.activityLogs = const [],
  });

  Color get statusColor {
    switch (status) {
      case TaskStatus.pending: return Colors.orange;
      case TaskStatus.inProgress: return Colors.blue;
      case TaskStatus.review: return Colors.purple;
      case TaskStatus.done: return Colors.green;
    }
  }

  double get totalHoursSpent {
    double total = 0;
    for (var log in timeLogs) {
      if (log.endTime != null) {
        total += log.duration.inMinutes / 60.0;
      }
    }
    return total;
  }
  
  bool get isTracking => timeLogs.isNotEmpty && timeLogs.last.endTime == null;
}
