import 'dart:convert';
import 'package:intl/intl.dart';
import '../storage/local_storage.dart';

class MockUser {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'Admin' | 'Manager' | 'Team Leader' | 'Team Member'
  final String department;
  final String phone;
  final String status; // 'Active' | 'Inactive'
  final String teamId; // Associated team (default 't1')
  bool isActive;
  String lastActive;
  int points;
  double productivityScore;
  double deadlineCommitment;
  double approvalRate;
  double rejectionRate;
  double leaderEvaluation;
  double finalScore;

  MockUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.department,
    this.phone = '+201012345678',
    this.status = 'Active',
    this.teamId = 't1',
    this.isActive = true,
    this.lastActive = 'Just now',
    this.points = 0,
    this.productivityScore = 80.0,
    this.deadlineCommitment = 90.0,
    this.approvalRate = 85.0,
    this.rejectionRate = 5.0,
    this.leaderEvaluation = 85.0,
    this.finalScore = 82.5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role,
        'department': department,
        'phone': phone,
        'status': status,
        'teamId': teamId,
        'isActive': isActive,
        'lastActive': lastActive,
        'points': points,
        'productivityScore': productivityScore,
        'deadlineCommitment': deadlineCommitment,
        'approvalRate': approvalRate,
        'rejectionRate': rejectionRate,
        'leaderEvaluation': leaderEvaluation,
        'finalScore': finalScore,
      };

  factory MockUser.fromJson(Map<String, dynamic> json) => MockUser(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String,
        department: json['department'] as String,
        phone: json['phone'] as String? ?? '+201012345678',
        status: json['status'] as String? ?? 'Active',
        teamId: json['teamId'] as String? ?? 't1',
        isActive: json['isActive'] as bool? ?? true,
        lastActive: json['lastActive'] as String? ?? 'Just now',
        points: json['points'] as int? ?? 0,
        productivityScore: (json['productivityScore'] as num? ?? 80.0).toDouble(),
        deadlineCommitment: (json['deadlineCommitment'] as num? ?? 90.0).toDouble(),
        approvalRate: (json['approvalRate'] as num? ?? 85.0).toDouble(),
        rejectionRate: (json['rejectionRate'] as num? ?? 5.0).toDouble(),
        leaderEvaluation: (json['leaderEvaluation'] as num? ?? 85.0).toDouble(),
        finalScore: (json['finalScore'] as num? ?? 82.5).toDouble(),
      );

  void recalculateFinalScore() {
    final double rejectionFactor = 100.0 - rejectionRate;
    finalScore = (productivityScore * 0.30) +
        (deadlineCommitment * 0.25) +
        (approvalRate * 0.25) +
        (rejectionFactor * 0.10) +
        (leaderEvaluation * 0.10);
  }
}

class MockChecklistItem {
  final String id;
  final String title;
  bool isDone;

  MockChecklistItem({required this.id, required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};
  factory MockChecklistItem.fromJson(Map<String, dynamic> json) => MockChecklistItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isDone: json['isDone'] as bool? ?? false,
      );
}

class MockTaskHistory {
  final String id;
  final String field;
  final String oldValue;
  final String newValue;
  final String updatedBy;
  final String date;

  MockTaskHistory({
    required this.id,
    required this.field,
    required this.oldValue,
    required this.newValue,
    required this.updatedBy,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'field': field,
        'oldValue': oldValue,
        'newValue': newValue,
        'updatedBy': updatedBy,
        'date': date,
      };

  factory MockTaskHistory.fromJson(Map<String, dynamic> json) => MockTaskHistory(
        id: json['id'] as String,
        field: json['field'] as String,
        oldValue: json['oldValue'] as String,
        newValue: json['newValue'] as String,
        updatedBy: json['updatedBy'] as String,
        date: json['date'] as String,
      );
}

class MockTaskActivity {
  final String id;
  final String user;
  final String action;
  final String date;
  final String? durationText;

  MockTaskActivity({
    required this.id,
    required this.user,
    required this.action,
    required this.date,
    this.durationText,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'action': action,
        'date': date,
        'durationText': durationText,
      };

  factory MockTaskActivity.fromJson(Map<String, dynamic> json) => MockTaskActivity(
        id: json['id'] as String,
        user: json['user'] as String,
        action: json['action'] as String,
        date: json['date'] as String,
        durationText: json['durationText'] as String?,
      );
}

class MockTaskComment {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final String date;
  final List<String> attachments;
  final String? replyToId;
  final String? replyToName;

  MockTaskComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.date,
    this.attachments = const [],
    this.replyToId,
    this.replyToName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'message': message,
        'date': date,
        'attachments': attachments,
        'replyToId': replyToId,
        'replyToName': replyToName,
      };

  factory MockTaskComment.fromJson(Map<String, dynamic> json) => MockTaskComment(
        id: json['id'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        message: json['message'] as String,
        date: json['date'] as String,
        attachments: List<String>.from(json['attachments'] as List? ?? []),
        replyToId: json['replyToId'] as String?,
        replyToName: json['replyToName'] as String?,
      );
}

class MockTask {
  final String id;
  final String ticketId;
  final String title;
  final String description;
  String assignedMemberId;
  final String deadline;
  final int estimatedHours;
  final String priority;
  String status; // 'Pending' | 'Assigned' | 'In Progress' | 'Submitted' | 'Under Review' | 'Approved' | 'Completed' | 'Needs Changes' | 'Reopened' | 'Rejected' | 'Overdue'
  List<String> attachments;
  String? githubLink;
  String? prLink;
  String? notes;
  String? submissionReport;
  String? leaderFeedback;
  String? managerFeedback;

  // New Fields
  final String assignmentMode; // 'Individual' | 'Team' | 'Department'
  final String? assignedTeamId;
  final String? assignedDepartment;
  final String? assignedRole;
  final String startDate;
  final String startTime;
  final String dueTime;
  final bool allowReassignment;
  final String assignedById;
  String currentOwnerId;
  final String taskDepartment;
  final String taskType; // 'Individual Task' | 'Team Task'
  final double estimatedTime; // in hours
  double actualTime; // accumulated in seconds
  bool timerRunning;
  int? timerStartTime; // milliseconds epoch
  final List<MockChecklistItem> checklist;
  final List<MockTaskHistory> history;
  final List<MockTaskActivity> activities;
  final List<MockTaskComment> comments;

  MockTask({
    required this.id,
    required this.ticketId,
    required this.title,
    required this.description,
    required this.assignedMemberId,
    required this.deadline,
    required this.estimatedHours,
    required this.priority,
    this.status = 'Pending',
    this.attachments = const [],
    this.githubLink,
    this.prLink,
    this.notes,
    this.submissionReport,
    this.leaderFeedback,
    this.managerFeedback,
    this.assignmentMode = 'Individual',
    this.assignedTeamId,
    this.assignedDepartment,
    this.assignedRole,
    this.startDate = '2026-07-24',
    this.startTime = '09:00',
    this.dueTime = '17:00',
    this.allowReassignment = false,
    this.assignedById = '1',
    this.currentOwnerId = '4',
    this.taskDepartment = 'Computer Science',
    this.taskType = 'Individual Task',
    this.estimatedTime = 8.0,
    this.actualTime = 0.0,
    this.timerRunning = false,
    this.timerStartTime,
    this.checklist = const [],
    this.history = const [],
    this.activities = const [],
    this.comments = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketId': ticketId,
        'title': title,
        'description': description,
        'assignedMemberId': assignedMemberId,
        'deadline': deadline,
        'estimatedHours': estimatedHours,
        'priority': priority,
        'status': status,
        'attachments': attachments,
        'githubLink': githubLink,
        'prLink': prLink,
        'notes': notes,
        'submissionReport': submissionReport,
        'leaderFeedback': leaderFeedback,
        'managerFeedback': managerFeedback,
        'assignmentMode': assignmentMode,
        'assignedTeamId': assignedTeamId,
        'assignedDepartment': assignedDepartment,
        'assignedRole': assignedRole,
        'startDate': startDate,
        'startTime': startTime,
        'dueTime': dueTime,
        'allowReassignment': allowReassignment,
        'assignedById': assignedById,
        'currentOwnerId': currentOwnerId,
        'taskDepartment': taskDepartment,
        'taskType': taskType,
        'estimatedTime': estimatedTime,
        'actualTime': actualTime,
        'timerRunning': timerRunning,
        'timerStartTime': timerStartTime,
        'checklist': checklist.map((x) => x.toJson()).toList(),
        'history': history.map((x) => x.toJson()).toList(),
        'activities': activities.map((x) => x.toJson()).toList(),
        'comments': comments.map((x) => x.toJson()).toList(),
      };

  factory MockTask.fromJson(Map<String, dynamic> json) => MockTask(
        id: json['id'] as String,
        ticketId: json['ticketId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        assignedMemberId: json['assignedMemberId'] as String,
        deadline: json['deadline'] as String,
        estimatedHours: json['estimatedHours'] as int,
        priority: json['priority'] as String,
        status: json['status'] as String,
        attachments: List<String>.from(json['attachments'] as List? ?? []),
        githubLink: json['githubLink'] as String?,
        prLink: json['prLink'] as String?,
        notes: json['notes'] as String?,
        submissionReport: json['submissionReport'] as String?,
        leaderFeedback: json['leaderFeedback'] as String?,
        managerFeedback: json['managerFeedback'] as String?,
        assignmentMode: json['assignmentMode'] as String? ?? 'Individual',
        assignedTeamId: json['assignedTeamId'] as String?,
        assignedDepartment: json['assignedDepartment'] as String?,
        assignedRole: json['assignedRole'] as String?,
        startDate: json['startDate'] as String? ?? '2026-07-24',
        startTime: json['startTime'] as String? ?? '09:00',
        dueTime: json['dueTime'] as String? ?? '17:00',
        allowReassignment: json['allowReassignment'] as bool? ?? false,
        assignedById: json['assignedById'] as String? ?? '1',
        currentOwnerId: json['currentOwnerId'] as String? ?? '4',
        taskDepartment: json['taskDepartment'] as String? ?? 'Computer Science',
        taskType: json['taskType'] as String? ?? 'Individual Task',
        estimatedTime: (json['estimatedTime'] as num? ?? 8.0).toDouble(),
        actualTime: (json['actualTime'] as num? ?? 0.0).toDouble(),
        timerRunning: json['timerRunning'] as bool? ?? false,
        timerStartTime: json['timerStartTime'] as int?,
        checklist: (json['checklist'] as List? ?? []).map((x) => MockChecklistItem.fromJson(x as Map<String, dynamic>)).toList(),
        history: (json['history'] as List? ?? []).map((x) => MockTaskHistory.fromJson(x as Map<String, dynamic>)).toList(),
        activities: (json['activities'] as List? ?? []).map((x) => MockTaskActivity.fromJson(x as Map<String, dynamic>)).toList(),
        comments: (json['comments'] as List? ?? []).map((x) => MockTaskComment.fromJson(x as Map<String, dynamic>)).toList(),
      );
}

class MockTeam {
  final String id;
  final String name;
  final String managerId;
  final String department;
  String leaderId;
  List<String> memberIds;
  double progress;

  MockTeam({
    required this.id,
    required this.name,
    required this.managerId,
    required this.department,
    required this.leaderId,
    required this.memberIds,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'managerId': managerId,
        'department': department,
        'leaderId': leaderId,
        'memberIds': memberIds,
        'progress': progress,
      };

  factory MockTeam.fromJson(Map<String, dynamic> json) => MockTeam(
        id: json['id'] as String,
        name: json['name'] as String,
        managerId: json['managerId'] as String,
        department: json['department'] as String? ?? 'Computer Science',
        leaderId: json['leaderId'] as String,
        memberIds: List<String>.from(json['memberIds'] as List),
        progress: (json['progress'] as num? ?? 0.0).toDouble(),
      );
}

class MockComplaint {
  final String id;
  final String submitterId;
  final String submitterName;
  final String submitterRole;
  final String targetType; // 'Member' | 'Team Leader' | 'Manager' | 'Team' | 'Workload Issue' | 'Deadline Issue'
  final String targetId;
  final String targetName;
  final String title;
  final String description;
  String status; // 'Open' | 'Under Investigation' | 'Resolved' | 'Closed'
  final String date;
  String investigationNotes;
  
  // Quality Integration
  String category; // 'Delay' | 'Poor Quality' | 'Communication' | 'Attendance' | 'Behavior' | 'Other'
  String resolution;
  String correctiveAction;
  bool warning;
  bool trainingRequired;
  String? closedById;
  String? closedDate;
  List<String> timeline;

  MockComplaint({
    required this.id,
    required this.submitterId,
    required this.submitterName,
    required this.submitterRole,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.title,
    required this.description,
    this.status = 'Open',
    required this.date,
    this.investigationNotes = '',
    this.category = 'Delay',
    this.resolution = '',
    this.correctiveAction = '',
    this.warning = false,
    this.trainingRequired = false,
    this.closedById,
    this.closedDate,
    this.timeline = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'submitterId': submitterId,
        'submitterName': submitterName,
        'submitterRole': submitterRole,
        'targetType': targetType,
        'targetId': targetId,
        'targetName': targetName,
        'title': title,
        'description': description,
        'status': status,
        'date': date,
        'investigationNotes': investigationNotes,
        'category': category,
        'resolution': resolution,
        'correctiveAction': correctiveAction,
        'warning': warning,
        'trainingRequired': trainingRequired,
        'closedById': closedById,
        'closedDate': closedDate,
        'timeline': timeline,
      };

  factory MockComplaint.fromJson(Map<String, dynamic> json) => MockComplaint(
        id: json['id'] as String,
        submitterId: json['submitterId'] as String,
        submitterName: json['submitterName'] as String,
        submitterRole: json['submitterRole'] as String,
        targetType: json['targetType'] as String,
        targetId: json['targetId'] as String,
        targetName: json['targetName'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        status: json['status'] as String,
        date: json['date'] as String,
        investigationNotes: json['investigationNotes'] as String? ?? json['resolutionNotes'] as String? ?? '',
        category: json['category'] as String? ?? 'Delay',
        resolution: json['resolution'] as String? ?? '',
        correctiveAction: json['correctiveAction'] as String? ?? '',
        warning: json['warning'] as bool? ?? false,
        trainingRequired: json['trainingRequired'] as bool? ?? false,
        closedById: json['closedById'] as String?,
        closedDate: json['closedDate'] as String?,
        timeline: List<String>.from(json['timeline'] as List? ?? []),
      );
}

class MockNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String date;
  bool isRead;

  MockNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'date': date,
        'isRead': isRead,
      };

  factory MockNotification.fromJson(Map<String, dynamic> json) => MockNotification(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        date: json['date'] as String,
        isRead: json['isRead'] as bool? ?? false,
      );
}

class MockDepartment {
  final String id;
  final String name;
  final String code;
  final String description;
  final String managerId; // MockUser ID
  final String createdDate;

  MockDepartment({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.managerId,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'description': description,
        'managerId': managerId,
        'createdDate': createdDate,
      };

  factory MockDepartment.fromJson(Map<String, dynamic> json) => MockDepartment(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        description: json['description'] as String,
        managerId: json['managerId'] as String,
        createdDate: json['createdDate'] as String,
      );
}

class MockRole {
  final String id;
  final String name;
  final String description;
  final Map<String, bool> permissions;

  MockRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'permissions': permissions,
      };

  factory MockRole.fromJson(Map<String, dynamic> json) => MockRole(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        permissions: Map<String, bool>.from(json['permissions'] as Map? ?? {}),
      );
}

class MockEvaluation {
  final String id;
  final String evaluatorId;
  final String employeeId;
  final double taskQuality; // 1-5
  final double communication; // 1-5
  final double teamwork; // 1-5
  final double discipline; // 1-5
  final double problemSolving; // 1-5
  final double deadlineCommitment; // 1-5
  final String managerNotes;
  final String recommendations;
  final String date;

  MockEvaluation({
    required this.id,
    required this.evaluatorId,
    required this.employeeId,
    required this.taskQuality,
    required this.communication,
    required this.teamwork,
    required this.discipline,
    required this.problemSolving,
    required this.deadlineCommitment,
    required this.managerNotes,
    required this.recommendations,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'evaluatorId': evaluatorId,
        'employeeId': employeeId,
        'taskQuality': taskQuality,
        'communication': communication,
        'teamwork': teamwork,
        'discipline': discipline,
        'problemSolving': problemSolving,
        'deadlineCommitment': deadlineCommitment,
        'managerNotes': managerNotes,
        'recommendations': recommendations,
        'date': date,
      };

  factory MockEvaluation.fromJson(Map<String, dynamic> json) => MockEvaluation(
        id: json['id'] as String,
        evaluatorId: json['evaluatorId'] as String,
        employeeId: json['employeeId'] as String,
        taskQuality: (json['taskQuality'] as num).toDouble(),
        communication: (json['communication'] as num).toDouble(),
        teamwork: (json['teamwork'] as num).toDouble(),
        discipline: (json['discipline'] as num).toDouble(),
        problemSolving: (json['problemSolving'] as num).toDouble(),
        deadlineCommitment: (json['deadlineCommitment'] as num).toDouble(),
        managerNotes: json['managerNotes'] as String? ?? '',
        recommendations: json['recommendations'] as String? ?? '',
        date: json['date'] as String,
      );
}

class MockAuditLog {
  final String id;
  final String userId;
  final String userEmail;
  final String operation;
  final String module;
  final String date;

  MockAuditLog({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.operation,
    required this.module,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userEmail': userEmail,
        'operation': operation,
        'module': module,
        'date': date,
      };

  factory MockAuditLog.fromJson(Map<String, dynamic> json) => MockAuditLog(
        id: json['id'] as String,
        userId: json['userId'] as String,
        userEmail: json['userEmail'] as String,
        operation: json['operation'] as String,
        module: json['module'] as String,
        date: json['date'] as String,
      );
}

class MockDatabase {
  MockDatabase._();

  static final MockDatabase instance = MockDatabase._();

  List<MockUser> _users = [];
  List<MockTeam> _teams = [];
  List<MockTask> _tasks = [];
  List<MockComplaint> _complaints = [];
  List<MockNotification> _notifications = [];
  List<MockDepartment> _departments = [];
  List<MockRole> _roles = [];
  List<MockEvaluation> _evaluations = [];
  List<MockAuditLog> _auditLogs = [];

  List<MockUser> get users => _users;
  List<MockTeam> get teams => _teams;
  List<MockTask> get tasks => _tasks;
  List<MockComplaint> get complaints => _complaints;
  List<MockNotification> get notifications => _notifications;
  List<MockDepartment> get departments => _departments;
  List<MockRole> get roles => _roles;
  List<MockEvaluation> get evaluations => _evaluations;
  List<MockAuditLog> get auditLogs => _auditLogs;

  Future<void> init() async {
    final String? data = LocalStorage.getString('mock_db_v6');
    if (data != null && data.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(data);
        _users = (map['users'] as List? ?? []).map((x) => MockUser.fromJson(x as Map<String, dynamic>)).toList();
        _teams = (map['teams'] as List? ?? []).map((x) => MockTeam.fromJson(x as Map<String, dynamic>)).toList();
        _tasks = (map['tasks'] as List? ?? []).map((x) => MockTask.fromJson(x as Map<String, dynamic>)).toList();
        _complaints = (map['complaints'] as List? ?? []).map((x) => MockComplaint.fromJson(x as Map<String, dynamic>)).toList();
        _notifications = (map['notifications'] as List? ?? []).map((x) => MockNotification.fromJson(x as Map<String, dynamic>)).toList();
        _departments = (map['departments'] as List? ?? []).map((x) => MockDepartment.fromJson(x as Map<String, dynamic>)).toList();
        _roles = (map['roles'] as List? ?? []).map((x) => MockRole.fromJson(x as Map<String, dynamic>)).toList();
        _evaluations = (map['evaluations'] as List? ?? []).map((x) => MockEvaluation.fromJson(x as Map<String, dynamic>)).toList();
        _auditLogs = (map['auditLogs'] as List? ?? []).map((x) => MockAuditLog.fromJson(x as Map<String, dynamic>)).toList();
      } catch (e) {
        // Fallback to defaults
      }
    }
    
    // Ensure lists are rich and never empty
    if (_users.isEmpty || _tasks.length < 8 || _departments.isEmpty || _roles.isEmpty || _teams.isEmpty) {
      _buildDefaults();
    }
    
    _checkOverdueRules();
    await save();
  }

  void _checkOverdueRules() {
    final now = DateTime.now();
    bool updated = false;
    for (final task in _tasks) {
      if (task.status != 'Completed' && task.status != 'Approved' && task.status != 'Overdue') {
        final due = DateTime.tryParse(task.deadline);
        if (due != null && due.isBefore(now)) {
          task.status = 'Overdue';
          updated = true;
          addNotification(
            userId: task.currentOwnerId,
            title: 'Task Overdue',
            message: 'Task exceeded its deadline: ${task.title}',
          );
        }
      }
    }
    if (updated) save();
  }

  void _buildDefaults() {
    _users = [
      MockUser(id: '1', email: 'admin@aitu.edu', fullName: 'Dr. Ahmed Hassan', role: 'Admin', department: 'Computer Science'),
      MockUser(id: '2', email: 'manager@aitu.edu', fullName: 'Prof. Khalid Mansour', role: 'Manager', department: 'Engineering'),
      MockUser(id: '3', email: 'leader@aitu.edu', fullName: 'Eng. Nour Hassan', role: 'Team Leader', department: 'Computer Science'),
      MockUser(id: '4', email: 'member@aitu.edu', fullName: 'Sarah Ahmed', role: 'Team Member', department: 'Computer Science', points: 35),
      MockUser(id: '5', email: 'member2@aitu.edu', fullName: 'Omar Khalil', role: 'Team Member', department: 'IT Services', points: 20),
    ];

    _teams = [
      MockTeam(id: 't1', name: 'Software Engineering Team', managerId: '2', department: 'Computer Science', leaderId: '3', memberIds: ['4', '5'], progress: 0.65),
      MockTeam(id: 't2', name: 'IT Infrastructure Team', managerId: '2', department: 'IT Services', leaderId: '3', memberIds: ['5'], progress: 0.45),
      MockTeam(id: 't3', name: 'Hardware & Lab Maintenance', managerId: '1', department: 'Engineering', leaderId: '3', memberIds: ['4'], progress: 0.80),
      MockTeam(id: 't4', name: 'Academic Quality Committee', managerId: '1', department: 'Computer Science', leaderId: '3', memberIds: ['4', '5'], progress: 0.90),
    ];

    _departments = [
      MockDepartment(id: 'd1', name: 'Computer Science', code: 'CS', description: 'Academic CS Dept', managerId: '1', createdDate: '2026-01-01'),
      MockDepartment(id: 'd2', name: 'Engineering', code: 'ENG', description: 'Academic ENG Dept', managerId: '2', createdDate: '2026-01-01'),
      MockDepartment(id: 'd3', name: 'IT Services', code: 'IT', description: 'University IT support', managerId: '2', createdDate: '2026-01-01'),
    ];

    final defaultPermissions = {
      'View Dashboard': true,
      'View Tasks': true,
      'Create Task': true,
      'Edit Task': true,
      'Delete Task': true,
      'Assign Task': true,
      'Reassign Task': true,
      'Complete Task': true,
      'View Task Details': true,
      'View Task History': true,
      'Comment On Task': true,
      'View Users': true,
      'Add User': true,
      'Edit User': true,
      'Delete User': true,
      'View Departments': true,
      'Add Department': true,
      'Edit Department': true,
      'Delete Department': true,
      'View Teams': true,
      'Add Team': true,
      'Edit Team': true,
      'Delete Team': true,
      'View Reports': true,
      'Export Reports': true,
      'View Complaints': true,
      'Reply': true,
      'Close Complaint': true,
      'View Evaluations': true,
      'Add Evaluation': true,
      'Edit Evaluation': true,
      'Manage Roles': true,
      'Manage Permissions': true,
      'Manage System Settings': true,
    };

    _roles = [
      MockRole(id: 'r1', name: 'Super Admin', description: 'System Root Administrator', permissions: defaultPermissions),
      MockRole(id: 'r2', name: 'Admin', description: 'Academic operations Admin', permissions: Map.from(defaultPermissions)),
      MockRole(id: 'r3', name: 'Manager', description: 'Department Manager', permissions: Map.from(defaultPermissions)),
      MockRole(id: 'r4', name: 'Team Leader', description: 'Task delegator and coordinator', permissions: Map.from(defaultPermissions)),
      MockRole(id: 'r5', name: 'Team Member', description: 'Active developer/researcher', permissions: Map.from(defaultPermissions)),
    ];

    _tasks = [
      MockTask(
        id: 'tsk1',
        ticketId: 'tic1',
        title: 'Design OAuth Flow',
        description: 'Wireframe OAuth screens and configure redirects.',
        assignedMemberId: '4',
        deadline: '2026-07-10',
        estimatedHours: 8,
        priority: 'HIGH',
        status: 'Completed',
        assignmentMode: 'Individual',
        assignedById: '1',
        currentOwnerId: '4',
        taskDepartment: 'Computer Science',
        taskType: 'Individual Task',
        checklist: [
          MockChecklistItem(id: 'c1', title: 'Analyze Requirements', isDone: true),
          MockChecklistItem(id: 'c2', title: 'Database Design', isDone: true),
        ],
        history: [
          MockTaskHistory(id: 'h1', field: 'Status', oldValue: 'Pending', newValue: 'Completed', updatedBy: 'Sarah Ahmed', date: '2026-07-10 10:00'),
        ],
        activities: [
          MockTaskActivity(id: 'a1', user: 'Dr. Ahmed Hassan', action: 'Task Created', date: '2026-07-01 09:00'),
        ],
        comments: [
          MockTaskComment(id: 'co1', userId: '1', userName: 'Dr. Ahmed Hassan', message: 'Please follow best design norms', date: '2026-07-01 09:15'),
        ],
      ),
      MockTask(
        id: 'tsk2',
        ticketId: 'tic2',
        title: 'Integrate API Constants',
        description: 'Align network endpoints with the server.',
        assignedMemberId: '4',
        deadline: '2026-07-12',
        estimatedHours: 4,
        priority: 'MEDIUM',
        status: 'Submitted',
        githubLink: 'https://github.com/aitu/tms',
        prLink: 'https://github.com/aitu/tms/pull/14',
        notes: 'API Constants are fully integrated. Ready for review.',
        submissionReport: 'I mapped all endpoints, defined constant URLs, and verified connectivity.',
        assignmentMode: 'Individual',
        assignedById: '1',
        currentOwnerId: '4',
        taskDepartment: 'Computer Science',
        taskType: 'Individual Task',
        checklist: [
          MockChecklistItem(id: 'ch3', title: 'API Development', isDone: true),
          MockChecklistItem(id: 'ch4', title: 'Testing', isDone: false),
        ],
      ),
      MockTask(
        id: 'tsk3',
        ticketId: 'tic3',
        title: 'Integrate fl_chart Package',
        description: 'Configure dynamic bar chart data bindings.',
        assignedMemberId: '5',
        deadline: '2026-07-28',
        estimatedHours: 12,
        priority: 'MEDIUM',
        status: 'In Progress',
        assignmentMode: 'Team',
        assignedTeamId: 't1',
        assignedById: '3',
        currentOwnerId: '5',
        taskDepartment: 'Computer Science',
        taskType: 'Team Task',
        checklist: [
          MockChecklistItem(id: 'ch5', title: 'Integrate fl_chart package', isDone: true),
          MockChecklistItem(id: 'ch6', title: 'Bind datasets', isDone: false),
        ],
      ),
      MockTask(
        id: 'tsk4',
        ticketId: 'tic4',
        title: 'Server Maintenance & Security Audit',
        description: 'Perform security patch installation and server log audit.',
        assignedMemberId: '5',
        deadline: '2026-07-18',
        estimatedHours: 6,
        priority: 'HIGH',
        status: 'Overdue',
        assignmentMode: 'Individual',
        assignedById: '2',
        currentOwnerId: '5',
        taskDepartment: 'IT Services',
        taskType: 'Individual Task',
        checklist: [
          MockChecklistItem(id: 'ch7', title: 'Check SSL certificates', isDone: true),
          MockChecklistItem(id: 'ch8', title: 'Update firewall rules', isDone: false),
        ],
      ),
      MockTask(
        id: 'tsk5',
        ticketId: 'tic5',
        title: 'Lab Electronics Inventory Inspection',
        description: 'Audit microcontrollers and hardware modules in Engineering lab 3.',
        assignedMemberId: '4',
        deadline: '2026-07-30',
        estimatedHours: 10,
        priority: 'LOW',
        status: 'Pending',
        assignmentMode: 'Team',
        assignedTeamId: 't3',
        assignedById: '2',
        currentOwnerId: '4',
        taskDepartment: 'Engineering',
        taskType: 'Team Task',
        checklist: [
          MockChecklistItem(id: 'ch9', title: 'Inspect oscilloscopes', isDone: false),
          MockChecklistItem(id: 'ch10', title: 'Catalog Arduino kits', isDone: false),
        ],
      ),
      MockTask(
        id: 'tsk6',
        ticketId: 'tic6',
        title: 'Academic Accreditation Report Drafting',
        description: 'Draft the compliance documentation for CS department quality review.',
        assignedMemberId: '3',
        deadline: '2026-08-05',
        estimatedHours: 15,
        priority: 'HIGH',
        status: 'In Progress',
        assignmentMode: 'Department',
        assignedDepartment: 'Computer Science',
        assignedById: '1',
        currentOwnerId: '3',
        taskDepartment: 'Computer Science',
        taskType: 'Team Task',
        checklist: [
          MockChecklistItem(id: 'ch11', title: 'Gather course specs', isDone: true),
          MockChecklistItem(id: 'ch12', title: 'Draft summary report', isDone: false),
        ],
      ),
      MockTask(
        id: 'tsk7',
        ticketId: 'tic7',
        title: 'Network Gateway Upgrade',
        description: 'Upgrade high-speed routers for campus backbone.',
        assignedMemberId: '5',
        deadline: '2026-07-29',
        estimatedHours: 5,
        priority: 'MEDIUM',
        status: 'Under Review',
        assignmentMode: 'Team',
        assignedTeamId: 't2',
        assignedById: '2',
        currentOwnerId: '5',
        taskDepartment: 'IT Services',
        taskType: 'Team Task',
        checklist: [
          MockChecklistItem(id: 'ch13', title: 'Backup configuration', isDone: true),
          MockChecklistItem(id: 'ch14', title: 'Flash firmware', isDone: true),
        ],
      ),
      MockTask(
        id: 'tsk8',
        ticketId: 'tic8',
        title: 'Database Schema Optimization',
        description: 'Create indexes and optimize query execution plans.',
        assignedMemberId: '4',
        deadline: '2026-07-15',
        estimatedHours: 6,
        priority: 'HIGH',
        status: 'Approved',
        assignmentMode: 'Individual',
        assignedById: '1',
        currentOwnerId: '4',
        taskDepartment: 'Computer Science',
        taskType: 'Individual Task',
        checklist: [
          MockChecklistItem(id: 'ch15', title: 'Index foreign keys', isDone: true),
          MockChecklistItem(id: 'ch16', title: 'Run explain analyze', isDone: true),
        ],
      ),
    ];

    _complaints = [
      MockComplaint(
        id: 'c1',
        submitterId: '4',
        submitterName: 'Sarah Ahmed',
        submitterRole: 'Team Member',
        targetType: 'Workload Issue',
        targetId: 't1',
        targetName: 'Software Engineering Team',
        title: 'Excessive exam schedule tasks',
        description: 'Concurrent project timelines overlap heavily with final exams preparation.',
        date: '2026-06-20',
        status: 'Under Investigation',
        category: 'Delay',
        timeline: ['Submitted on 2026-06-20', 'Under investigation by Prof. Khalid Mansour'],
      ),
      MockComplaint(
        id: 'c2',
        submitterId: '5',
        submitterName: 'Omar Khalil',
        submitterRole: 'Team Member',
        targetType: 'Deadline Issue',
        targetId: 't2',
        targetName: 'IT Infrastructure Team',
        title: 'Server maintenance timeline conflict',
        description: 'Scheduled downtime coincides with student registration hours.',
        date: '2026-07-02',
        status: 'Open',
        category: 'Delay',
        timeline: ['Submitted on 2026-07-02'],
      ),
      MockComplaint(
        id: 'c3',
        submitterId: '3',
        submitterName: 'Eng. Nour Hassan',
        submitterRole: 'Team Leader',
        targetType: 'Member',
        targetId: '5',
        targetName: 'Omar Khalil',
        title: 'Delayed deliverable submission',
        description: 'Deliverables for IT module submitted past agreed deadline.',
        date: '2026-07-10',
        status: 'Resolved',
        category: 'Delay',
        resolution: 'Re-assigned timeline with clear milestones.',
        correctiveAction: 'Weekly progress check-in scheduled.',
        timeline: ['Submitted on 2026-07-10', 'Resolved on 2026-07-12 by Dr. Ahmed Hassan'],
      ),
    ];

    _evaluations = [
      MockEvaluation(
        id: 'e1',
        evaluatorId: '3',
        employeeId: '4',
        taskQuality: 4.5,
        communication: 4.0,
        teamwork: 5.0,
        discipline: 4.5,
        problemSolving: 4.0,
        deadlineCommitment: 4.8,
        managerNotes: 'Sarah behaves professionally and commits to tasks.',
        recommendations: 'Highly productive member.',
        date: '2026-07-15',
      ),
      MockEvaluation(
        id: 'e2',
        evaluatorId: '3',
        employeeId: '5',
        taskQuality: 4.0,
        communication: 3.8,
        teamwork: 4.2,
        discipline: 4.0,
        problemSolving: 4.1,
        deadlineCommitment: 3.9,
        managerNotes: 'Omar shows good technical initiative on IT infrastructure tasks.',
        recommendations: 'Focus on deadline estimation.',
        date: '2026-07-18',
      ),
    ];

    _notifications = [
      MockNotification(id: 'n1', userId: '4', title: 'Task Assigned', message: 'You have been assigned the task: Design OAuth Flow', date: '2026-07-01'),
      MockNotification(id: 'n2', userId: '5', title: 'Task Assigned', message: 'You have been assigned the task: Integrate fl_chart Package', date: '2026-07-05'),
    ];

    _auditLogs = [
      MockAuditLog(id: 'a1', userId: '1', userEmail: 'admin@aitu.edu', operation: 'User Added: member@aitu.edu', module: 'Users', date: '2026-07-01 09:30'),
      MockAuditLog(id: 'a2', userId: '1', userEmail: 'admin@aitu.edu', operation: 'Department Added: IT Services', module: 'Departments', date: '2026-07-02 11:15'),
    ];
  }

  Future<void> save() async {
    final map = {
      'users': _users.map((x) => x.toJson()).toList(),
      'teams': _teams.map((x) => x.toJson()).toList(),
      'tasks': _tasks.map((x) => x.toJson()).toList(),
      'complaints': _complaints.map((x) => x.toJson()).toList(),
      'notifications': _notifications.map((x) => x.toJson()).toList(),
      'departments': _departments.map((x) => x.toJson()).toList(),
      'roles': _roles.map((x) => x.toJson()).toList(),
      'evaluations': _evaluations.map((x) => x.toJson()).toList(),
      'auditLogs': _auditLogs.map((x) => x.toJson()).toList(),
    };
    await LocalStorage.setString('mock_db_v6', jsonEncode(map));
  }

  MockUser? login(String email, String password) {
    final user = _users.firstWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => throw Exception('User not found. Test emails: admin@aitu.edu, manager@aitu.edu, leader@aitu.edu, member@aitu.edu'));
    user.isActive = true;
    user.lastActive = 'Just now';
    save();
    return user;
  }

  // --- Audit Logging helper ---
  void logAdminAction(String userId, String operation, String module) {
    final user = _users.firstWhere((u) => u.id == userId, orElse: () => MockUser(id: '', email: 'system@aitu.edu', fullName: 'System', role: '', department: ''));
    _auditLogs.insert(
      0,
      MockAuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userEmail: user.email,
        operation: operation,
        module: module,
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      ),
    );
    save();
  }

  // --- User CRUD ---
  void addUser(MockUser user, [String adminUserId = '1']) {
    if (_users.any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
      throw Exception('User with this email already exists.');
    }
    _users.add(user);
    logAdminAction(adminUserId, 'Added User: ${user.fullName} (${user.email})', 'Users');
    save();
  }

  void deleteUser(String id, [String adminUserId = '1']) {
    final u = _users.firstWhere((u) => u.id == id, orElse: () => MockUser(id: '', email: '', fullName: '', role: '', department: ''));
    _users.removeWhere((u) => u.id == id);
    logAdminAction(adminUserId, 'Deleted User: ${u.fullName} (${u.email})', 'Users');
    save();
  }

  void editUser(MockUser user, [String adminUserId = '1']) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
      logAdminAction(adminUserId, 'Updated User: ${user.fullName}', 'Users');
      save();
    }
  }

  // --- Department CRUD ---
  void addDepartment(MockDepartment dept, [String adminUserId = '1']) {
    _departments.add(dept);
    logAdminAction(adminUserId, 'Added Department: ${dept.name} (${dept.code})', 'Departments');
    save();
  }

  void editDepartment(MockDepartment dept, [String adminUserId = '1']) {
    final idx = _departments.indexWhere((d) => d.id == dept.id);
    if (idx != -1) {
      _departments[idx] = dept;
      logAdminAction(adminUserId, 'Updated Department: ${dept.name}', 'Departments');
      save();
    }
  }

  void deleteDepartment(String id, [String adminUserId = '1']) {
    final d = _departments.firstWhere((d) => d.id == id, orElse: () => MockDepartment(id: '', name: '', code: '', description: '', managerId: '', createdDate: ''));
    _departments.removeWhere((d) => d.id == id);
    logAdminAction(adminUserId, 'Deleted Department: ${d.name}', 'Departments');
    save();
  }

  // --- Roles & Permissions CRUD ---
  void addRole(MockRole role, [String adminUserId = '1']) {
    _roles.add(role);
    logAdminAction(adminUserId, 'Added Role: ${role.name}', 'Roles');
    save();
  }

  void editRole(MockRole role, [String adminUserId = '1']) {
    if (role.name == 'Super Admin') {
      throw Exception('Super Admin role permissions are locked.');
    }
    final idx = _roles.indexWhere((r) => r.id == role.id);
    if (idx != -1) {
      _roles[idx] = role;
      logAdminAction(adminUserId, 'Updated Role: ${role.name}', 'Roles');
      save();
    }
  }

  void deleteRole(String id, [String adminUserId = '1']) {
    final r = _roles.firstWhere((r) => r.id == id, orElse: () => MockRole(id: '', name: '', description: '', permissions: {}));
    if (r.name == 'Super Admin') {
      throw Exception('Super Admin role cannot be deleted.');
    }
    _roles.removeWhere((r) => r.id == id);
    logAdminAction(adminUserId, 'Deleted Role: ${r.name}', 'Roles');
    save();
  }

  // --- Evaluation CRUD ---
  void addEvaluation(MockEvaluation eval, [String adminUserId = '1']) {
    _evaluations.add(eval);
    logAdminAction(adminUserId, 'Added Performance Evaluation for Employee ID: ${eval.employeeId}', 'Evaluations');
    
    // Update active user scores
    final idx = _users.indexWhere((u) => u.id == eval.employeeId);
    if (idx != -1) {
      final user = _users[idx];
      user.productivityScore = eval.taskQuality * 20;
      user.deadlineCommitment = eval.deadlineCommitment * 20;
      user.leaderEvaluation = eval.teamwork * 20;
      user.recalculateFinalScore();
    }
    save();
  }

  // --- Complaints System with Resolution timelines ---
  void addComplaint(MockComplaint comp) {
    _complaints.add(comp);
    save();
  }

  void resolveComplaint({
    required String complaintId,
    required String investigationNotes,
    required String resolution,
    required String correctiveAction,
    required bool warning,
    required bool trainingRequired,
    required String closedByUserId,
  }) {
    final idx = _complaints.indexWhere((c) => c.id == complaintId);
    if (idx != -1) {
      final c = _complaints[idx];
      c.status = 'Resolved';
      c.investigationNotes = investigationNotes;
      c.resolution = resolution;
      c.correctiveAction = correctiveAction;
      c.warning = warning;
      c.trainingRequired = trainingRequired;
      c.closedById = closedByUserId;
      c.closedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      c.timeline.add('Resolved on ${c.closedDate} by Manager');
      
      logAdminAction(closedByUserId, 'Resolved Complaint: ${c.title}', 'Complaints');
      save();
    }
  }

  // --- Tasks Operations ---
  void addTask(MockTask task) {
    _tasks.add(task);
    addNotification(
      userId: task.currentOwnerId,
      title: 'Task Assigned',
      message: 'You have been assigned a new task: ${task.title}',
    );
    save();
  }

  void delegateTask(String taskId, String newOwnerId, {String? delegatorName}) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final oldOwnerId = task.currentOwnerId;
      task.currentOwnerId = newOwnerId;
      task.assignedMemberId = newOwnerId;
      
      // Save delegation audit log
      task.history.add(
        MockTaskHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          field: 'Current Owner',
          oldValue: oldOwnerId,
          newValue: newOwnerId,
          updatedBy: delegatorName ?? 'Manager',
          date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        ),
      );
      task.activities.add(
        MockTaskActivity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          user: delegatorName ?? 'Manager',
          action: 'Reassigned task to ${users.firstWhere((u) => u.id == newOwnerId).fullName}',
          date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        ),
      );

      addNotification(
        userId: newOwnerId,
        title: 'Task Reassigned',
        message: 'A task has been delegated to you: ${task.title}',
      );
      save();
    }
  }

  void updateTaskChecklist(String taskId, List<MockChecklistItem> newChecklist) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.checklist.clear();
      task.checklist.addAll(newChecklist);
      save();
    }
  }

  void updateTaskTime(String taskId, double actualTimeSeconds) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].actualTime = actualTimeSeconds;
      save();
    }
  }

  void updateTaskTimerState(String taskId, bool isRunning, int? startTime) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].timerRunning = isRunning;
      _tasks[idx].timerStartTime = startTime;
      save();
    }
  }

  void addTaskComment(String taskId, MockTaskComment comment) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].comments.add(comment);
      _tasks[idx].activities.add(
        MockTaskActivity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          user: comment.userName,
          action: 'Comment Added: "${comment.message.length > 20 ? comment.message.substring(0, 20) + '...' : comment.message}"',
          date: comment.date,
        ),
      );
      save();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    save();
  }

  void updateTaskStatus(String taskId, String newStatus, String updatedByUser) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      final old = task.status;
      task.status = newStatus;
      
      task.history.add(MockTaskHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        field: 'Status',
        oldValue: old,
        newValue: newStatus,
        updatedBy: updatedByUser,
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      ));
      task.activities.add(MockTaskActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: updatedByUser,
        action: 'Status changed to $newStatus',
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      ));
      save();
    }
  }

  void submitTask({
    required String taskId,
    required String githubLink,
    required String prLink,
    required String notes,
    required String report,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.status = 'Submitted';
      task.githubLink = githubLink;
      task.prLink = prLink;
      task.notes = notes;
      task.submissionReport = report;
      
      task.activities.add(MockTaskActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: 'Employee',
        action: 'Submitted task deliverables',
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      ));
      save();
    }
  }

  // --- Notifications Helper ---
  void addNotification({
    required String userId,
    required String title,
    required String message,
  }) {
    _notifications.insert(
      0,
      MockNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        message: message,
        date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      ),
    );
    save();
  }

  void markNotificationsRead(String userId) {
    for (var n in _notifications) {
      if (n.userId == userId) {
        n.isRead = true;
      }
    }
    save();
  }

  void markSingleNotificationRead(String notificationId, bool read) {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _notifications[idx].isRead = read;
      save();
    }
  }

  void addTeam(MockTeam team) {
    _teams.add(team);
    save();
  }

  void reviewTask({
    required String taskId,
    required String status,
    required String feedback,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      task.status = status;
      task.leaderFeedback = feedback;
      task.notes = feedback;
      save();
    }
  }
}
