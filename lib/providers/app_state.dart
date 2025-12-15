import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart'; 
import 'package:file_picker/file_picker.dart'; 
import '../models/task.dart';
import '../models/user.dart';
import '../models/activity_log.dart';

class AppState extends ChangeNotifier {
  // Mock Data
  final User _superior = User(id: 'u1', name: 'Alice Manager', role: UserRole.superior, profileImage: null);
  final User _subordinate = User(id: 'u2', name: 'Bob Worker', role: UserRole.subordinate);
  final User _subordinate2 = User(id: 'u3', name: 'Charlie Dev', role: UserRole.subordinate);

  late User _currentUser;
  List<User> _users = [];
  List<Task> _tasks = [];
  
  // Theme
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark for "premium" feel
  
  // Search & Filter
  String _searchQuery = '';
  List<TaskPriority> _activePriorityFilters = [];
  bool _showOverdueOnly = false;

  // Getters
  User get currentUser => _currentUser;
  List<User> get allUsers => _users;
  List<Task> get allTasks => _tasks;
  ThemeMode get themeMode => _themeMode;
  
  // Navigation
  int _activeTab = 0; // 0: Dashboard, 1: Calendar 
  int get activeTab => _activeTab;

  void setActiveTab(int index) {
    _activeTab = index;
    notifyListeners();
  }
  
  List<Task> get myTasks {
    if (_currentUser.role == UserRole.subordinate) {
      return _tasks.where((t) => t.assigneeId == _currentUser.id).toList();
    }
    return _tasks;
  }
  
  List<Task> get pendingTasks => _tasks.where((t) => t.status != TaskStatus.done).toList();
  
  List<Task> get filteredTasks {
    return _tasks.where((task) {
      // Search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) && !task.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Priority Filter
      if (_activePriorityFilters.isNotEmpty) {
        if (!_activePriorityFilters.contains(task.priority)) {
          return false;
        }
      }
      
      // Overdue Filter
      if (_showOverdueOnly) {
         if (task.dueDate.isAfter(DateTime.now()) || task.status == TaskStatus.done) {
           return false;
         }
      }
      
      return true;
    }).toList();
  }
  
  // Gamification Stats
  List<User> get topPerformers {
    var sortedUsers = List<User>.from(_users.where((u) => u.role == UserRole.subordinate));
    sortedUsers.sort((a, b) => b.tasksCompleted.compareTo(a.tasksCompleted));
    return sortedUsers;
  }

  AppState() {
    _users = [_superior, _subordinate, _subordinate2];
    _currentUser = _superior; 
    _seedTasks();
  }

  // --- ACTIONS ---

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void togglePriorityFilter(TaskPriority priority) {
    if (_activePriorityFilters.contains(priority)) {
      _activePriorityFilters.remove(priority);
    } else {
      _activePriorityFilters.add(priority);
    }
    notifyListeners();
  }
  
  void toggleOverdueFilter() {
    _showOverdueOnly = !_showOverdueOnly;
    notifyListeners();
  }
  
  bool isPriorityFilterActive(TaskPriority p) => _activePriorityFilters.contains(p);
  bool get isOverdueFilterActive => _showOverdueOnly;

  void switchUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
  
  void addUser(String name) {
    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      role: UserRole.subordinate,
    );
    _users.add(newUser);
    notifyListeners();
  }

  void addTask({
    required String title, 
    required String description, 
    required String assigneeId, 
    required DateTime dueDate,
    RecurrenceInterval recurrence = RecurrenceInterval.none,
  }) {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      assigneeId: assigneeId,
      creatorId: _currentUser.id,
      dueDate: dueDate,
      status: TaskStatus.pending,
      recurrence: recurrence,
    );
    _tasks.add(newTask);
    _logActivity(newTask, "Task created by ${_currentUser.name}");
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus status, double progress) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final oldStatus = task.status;
      task.status = status;
      task.progress = progress;
      
      if (oldStatus != status) {
        _logActivity(task, "Status changed from ${oldStatus.name} to ${status.name}");
      }
      
      // Close recurring task logic
      if (status == TaskStatus.done && task.recurrence != RecurrenceInterval.none) {
         _handleRecurrence(task);
      }
      
      notifyListeners();
    }
  }

  void _handleRecurrence(Task completedTask) {
    DateTime nextDue;
    switch (completedTask.recurrence) {
      case RecurrenceInterval.daily:
        nextDue = completedTask.dueDate.add(const Duration(days: 1));
        break;
      case RecurrenceInterval.weekly:
        nextDue = completedTask.dueDate.add(const Duration(days: 7));
        break;
      case RecurrenceInterval.monthly:
        nextDue = DateTime(completedTask.dueDate.year, completedTask.dueDate.month + 1, completedTask.dueDate.day);
        break;
      default:
        return;
    }
    
    // Create Next Task
    final newTask = Task(
      id: const Uuid().v4(),
      title: completedTask.title,
      description: completedTask.description,
      assigneeId: completedTask.assigneeId,
      creatorId: completedTask.creatorId,
      dueDate: nextDue,
      status: TaskStatus.pending,
      recurrence: completedTask.recurrence,
    );
    _tasks.add(newTask);
    _logActivity(newTask, "Recurring task created automatically");
  }

  void addComment(String taskId, String content) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      task.comments.add(Comment(
        id: const Uuid().v4(),
        authorId: _currentUser.id,
        content: content,
        timestamp: DateTime.now(),
      ));
      _logActivity(task, "Comment added by ${_currentUser.name}");
      notifyListeners();
    }
  }

  void toggleTimeTracking(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      if (task.isTracking) {
        // Stop
        final lastLog = task.timeLogs.last;
        final updatedLog = TimeEntry(
           id: lastLog.id, 
           userId: lastLog.userId,
           startTime: lastLog.startTime,
           endTime: DateTime.now()
        );
        task.timeLogs.removeLast();
        task.timeLogs.add(updatedLog);
        _logActivity(task, "Time tracking stopped. Duration: ${updatedLog.duration.inMinutes} mins");
      } else {
        // Start
        task.timeLogs.add(TimeEntry(
          id: const Uuid().v4(),
          userId: _currentUser.id,
          startTime: DateTime.now(),
        ));
        _logActivity(task, "Time tracking started by ${_currentUser.name}");
      }
      notifyListeners();
    }
  }
  
  void addAttachment(String taskId, String fileName) {
     final index = _tasks.indexWhere((t) => t.id == taskId);
     if (index != -1) {
       final task = _tasks[index];
       task.attachments.add(fileName);
       _logActivity(task, "File attached: $fileName");
       notifyListeners();
     }
  }
  
  void _logActivity(Task task, String description) {
    task.activityLogs.add(ActivityLog(
      id: const Uuid().v4(), 
      userId: _currentUser.id, 
      description: description, 
      timestamp: DateTime.now()
    ));
  }

  Future<String> generateCsvReport() async {
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Title", "Status", "Assignee", "Due Date", "Time Spent (Hrs)"]);
    
    for (var task in _tasks) {
      final assignee = _users.firstWhere((u) => u.id == task.assigneeId, orElse: () => User(id: '', name: 'Unknown', role: UserRole.subordinate));
      rows.add([
        task.id,
        task.title,
        task.status.name,
        assignee.name,
        DateFormat('yyyy-MM-dd').format(task.dueDate),
        task.totalHoursSpent.toStringAsFixed(2)
      ]);
    }
    
    String csv = const ListToCsvConverter().convert(rows);
    print("CSV Report Generated:\n$csv");
    return csv;
  }

  void _seedTasks() {
    _tasks = [
      Task(id: 't1', title: 'Q1 Report', description: 'Analyze sales data', assigneeId: 'u2', creatorId: 'u1', dueDate: DateTime.now().add(Duration(days: 2)), status: TaskStatus.inProgress, progress: 0.4),
      Task(id: 't2', title: 'Fix Bug #102', description: 'Login crash on iOS', assigneeId: 'u3', creatorId: 'u1', dueDate: DateTime.now().add(Duration(days: 1)), status: TaskStatus.pending, progress: 0.0, priority: TaskPriority.high),
      Task(id: 't3', title: 'Update Website', description: 'New landing page', assigneeId: 'u2', creatorId: 'u1', dueDate: DateTime.now().subtract(Duration(days: 1)), status: TaskStatus.review, progress: 0.9),
    ];
  }
}
