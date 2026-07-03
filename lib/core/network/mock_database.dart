import 'dart:convert';
import '../storage/local_storage.dart';

class MockUser {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'Admin' | 'Manager' | 'Team Leader' | 'Team Member'
  final String department;
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

class MockProject {
  final String id;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String priority; // 'HIGH' | 'MEDIUM' | 'LOW'
  String status; // 'Pending' | 'In Progress' | 'Completed' | 'Suspended'
  String? assignedLeaderId;

  MockProject({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.status,
    this.assignedLeaderId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'priority': priority,
        'status': status,
        'assignedLeaderId': assignedLeaderId,
      };

  factory MockProject.fromJson(Map<String, dynamic> json) => MockProject(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        startDate: json['startDate'] as String,
        endDate: json['endDate'] as String,
        priority: json['priority'] as String,
        status: json['status'] as String,
        assignedLeaderId: json['assignedLeaderId'] as String?,
      );
}

class MockTeam {
  final String id;
  final String name;
  final String managerId;
  String leaderId;
  List<String> memberIds;
  double progress;

  MockTeam({
    required this.id,
    required this.name,
    required this.managerId,
    required this.leaderId,
    required this.memberIds,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'managerId': managerId,
        'leaderId': leaderId,
        'memberIds': memberIds,
        'progress': progress,
      };

  factory MockTeam.fromJson(Map<String, dynamic> json) => MockTeam(
        id: json['id'] as String,
        name: json['name'] as String,
        managerId: json['managerId'] as String,
        leaderId: json['leaderId'] as String,
        memberIds: List<String>.from(json['memberIds'] as List),
        progress: (json['progress'] as num? ?? 0.0).toDouble(),
      );
}

class MockTicket {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String deadline;
  final String teamId;
  double progressPercentage;
  String status; // 'Open' | 'In Progress' | 'Under Review' | 'Completed'
  List<String> attachments;

  MockTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.deadline,
    required this.teamId,
    this.progressPercentage = 0.0,
    this.status = 'Open',
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority,
        'deadline': deadline,
        'teamId': teamId,
        'progressPercentage': progressPercentage,
        'status': status,
        'attachments': attachments,
      };

  factory MockTicket.fromJson(Map<String, dynamic> json) => MockTicket(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        priority: json['priority'] as String,
        deadline: json['deadline'] as String,
        teamId: json['teamId'] as String,
        progressPercentage: (json['progressPercentage'] as num? ?? 0.0).toDouble(),
        status: json['status'] as String,
        attachments: List<String>.from(json['attachments'] as List? ?? []),
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
  String status; // 'Pending' | 'Assigned' | 'In Progress' | 'Submitted' | 'Under Review' | 'Approved' | 'Completed' | 'Needs Changes' | 'Reopened' | 'Rejected'
  List<String> attachments;
  String? githubLink;
  String? prLink;
  String? notes;
  String? submissionReport;
  String? leaderFeedback;
  String? managerFeedback;

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
  String resolutionNotes;

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
    this.resolutionNotes = '',
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
        'resolutionNotes': resolutionNotes,
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
        resolutionNotes: json['resolutionNotes'] as String? ?? '',
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

class MockDatabase {
  MockDatabase._();

  static final MockDatabase instance = MockDatabase._();

  List<MockUser> _users = [];
  List<MockProject> _projects = [];
  List<MockTeam> _teams = [];
  List<MockTicket> _tickets = [];
  List<MockTask> _tasks = [];
  List<MockComplaint> _complaints = [];
  List<MockNotification> _notifications = [];

  List<MockUser> get users => _users;
  List<MockProject> get projects => _projects;
  List<MockTeam> get teams => _teams;
  List<MockTicket> get tickets => _tickets;
  List<MockTask> get tasks => _tasks;
  List<MockComplaint> get complaints => _complaints;
  List<MockNotification> get notifications => _notifications;

  Future<void> init() async {
    final String? data = LocalStorage.getString('mock_db_v2');
    if (data != null && data.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(data);
        _users = (map['users'] as List).map((x) => MockUser.fromJson(x as Map<String, dynamic>)).toList();
        _projects = (map['projects'] as List).map((x) => MockProject.fromJson(x as Map<String, dynamic>)).toList();
        _teams = (map['teams'] as List).map((x) => MockTeam.fromJson(x as Map<String, dynamic>)).toList();
        _tickets = (map['tickets'] as List).map((x) => MockTicket.fromJson(x as Map<String, dynamic>)).toList();
        _tasks = (map['tasks'] as List).map((x) => MockTask.fromJson(x as Map<String, dynamic>)).toList();
        _complaints = (map['complaints'] as List).map((x) => MockComplaint.fromJson(x as Map<String, dynamic>)).toList();
        _notifications = (map['notifications'] as List).map((x) => MockNotification.fromJson(x as Map<String, dynamic>)).toList();
        return;
      } catch (e) {
        // Build defaults on failure
      }
    }
    _buildDefaults();
    await save();
  }

  void _buildDefaults() {
    _users = [
      MockUser(id: '1', email: 'admin@aitu.edu', fullName: 'Dr. Ahmed Hassan', role: 'Admin', department: 'Computer Science'),
      MockUser(id: '2', email: 'manager@aitu.edu', fullName: 'Prof. Khalid Mansour', role: 'Manager', department: 'Engineering'),
      MockUser(id: '3', email: 'leader@aitu.edu', fullName: 'Eng. Nour Hassan', role: 'Team Leader', department: 'Computer Science'),
      MockUser(id: '4', email: 'member@aitu.edu', fullName: 'Sarah Ahmed', role: 'Team Member', department: 'Computer Science', points: 35),
      MockUser(id: '5', email: 'member2@aitu.edu', fullName: 'Omar Khalil', role: 'Team Member', department: 'IT Services', points: 20),
    ];

    _projects = [
      MockProject(id: 'p1', name: 'Faculty Website Project', description: 'Redesign and develop the technological portal for AITU faculty departments.', startDate: '2026-06-01', endDate: '2026-09-30', priority: 'HIGH', status: 'In Progress', assignedLeaderId: '3'),
      MockProject(id: 'p2', name: 'Smart Village Project', description: 'Implement building automation sensors and energy optimization scripts.', startDate: '2026-07-10', endDate: '2026-12-15', priority: 'MEDIUM', status: 'Pending', assignedLeaderId: '3'),
      MockProject(id: 'p3', name: 'Graduation Project', description: 'Student attendance tracking with Bluetooth beacons and Flutter frontend.', startDate: '2026-05-15', endDate: '2026-07-20', priority: 'HIGH', status: 'In Progress', assignedLeaderId: '3'),
    ];

    _teams = [
      MockTeam(id: 't1', name: 'Software Engineering Team', managerId: '2', leaderId: '3', memberIds: ['4', '5'], progress: 65.0),
    ];

    _tickets = [
      MockTicket(id: 'tic1', title: 'Build Authentication Module', description: 'Create security layouts and JWT validation mechanism.', priority: 'HIGH', deadline: '2026-07-15', teamId: 't1', progressPercentage: 70.0, status: 'In Progress'),
      MockTicket(id: 'tic2', title: 'Build Dashboard', description: 'Create responsive analytics views and charts.', priority: 'MEDIUM', deadline: '2026-07-25', teamId: 't1', progressPercentage: 40.0, status: 'In Progress'),
      MockTicket(id: 'tic3', title: 'Develop User Management Module', description: 'Develop admin sub-modules to invite and delete members.', priority: 'HIGH', deadline: '2026-07-05', teamId: 't1', progressPercentage: 100.0, status: 'Completed'),
    ];

    _tasks = [
      MockTask(id: 'tsk1', ticketId: 'tic1', title: 'Design OAuth Flow', description: 'Wireframe OAuth screens and configure redirects.', assignedMemberId: '4', deadline: '2026-07-10', estimatedHours: 8, priority: 'HIGH', status: 'Completed'),
      MockTask(
        id: 'tsk2',
        ticketId: 'tic1',
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
      ),
      MockTask(id: 'tsk3', ticketId: 'tic2', title: 'Integrate fl_chart', description: 'Configure dynamic bar chart data bindings.', assignedMemberId: '5', deadline: '2026-07-20', estimatedHours: 12, priority: 'MEDIUM', status: 'Assigned'),
      MockTask(id: 'tsk4', ticketId: 'tic3', title: 'Create Users Table Layout', description: 'Implement tabular lists and role filter tabs.', assignedMemberId: '4', deadline: '2026-07-02', estimatedHours: 6, priority: 'HIGH', status: 'Completed', githubLink: 'https://github.com/aitu/tms', prLink: 'https://github.com/aitu/tms/pull/12', notes: 'Completed.', submissionReport: 'Finished implementation and verification.'),
    ];

    _complaints = [
      MockComplaint(id: 'c1', submitterId: '4', submitterName: 'Sarah Ahmed', submitterRole: 'Team Member', targetType: 'Workload Issue', targetId: 't1', targetName: 'Software Engineering Team', title: 'Excessive exam schedule tasks', description: 'Concurrent project timelines overlap heavily with final exams preparation.', date: '2026-06-20', status: 'Under Investigation'),
    ];

    _notifications = [
      MockNotification(id: 'n1', userId: '4', title: 'Task Assigned', message: 'You have been assigned the task: Integrate fl_chart', date: '2026-07-01'),
      MockNotification(id: 'n2', userId: '3', title: 'Submission Received', message: 'Sarah Ahmed submitted task: Create Users Table Layout', date: '2026-07-02'),
    ];
  }

  Future<void> save() async {
    final map = {
      'users': _users.map((x) => x.toJson()).toList(),
      'projects': _projects.map((x) => x.toJson()).toList(),
      'teams': _teams.map((x) => x.toJson()).toList(),
      'tickets': _tickets.map((x) => x.toJson()).toList(),
      'tasks': _tasks.map((x) => x.toJson()).toList(),
      'complaints': _complaints.map((x) => x.toJson()).toList(),
      'notifications': _notifications.map((x) => x.toJson()).toList(),
    };
    await LocalStorage.setString('mock_db_v2', jsonEncode(map));
  }

  MockUser? login(String email, String password) {
    final user = _users.firstWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => throw Exception('User not found. Test emails: admin@aitu.edu, manager@aitu.edu, leader@aitu.edu, member@aitu.edu'));
    user.isActive = true;
    user.lastActive = 'Just now';
    save();
    return user;
  }

  void addUser(MockUser user) {
    if (_users.any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
      throw Exception('User with this email already exists.');
    }
    _users.add(user);
    save();
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    save();
  }

  void editUser(MockUser user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
      save();
    }
  }

  void addProject(MockProject project) {
    _projects.add(project);
    save();
  }

  void assignProject(String projectId, String leaderId) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      _projects[idx].assignedLeaderId = leaderId;
      _projects[idx].status = 'In Progress';
      save();
    }
  }

  void addTeam(MockTeam team) {
    _teams.add(team);
    save();
  }

  void addTicket(MockTicket ticket) {
    _tickets.add(ticket);
    save();
  }

  void updateTicketStatus(String ticketId, String status) {
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx].status = status;
      save();
    }
  }

  void addTask(MockTask task) {
    _tasks.add(task);
    addNotification(
      userId: task.assignedMemberId,
      title: 'Task Assigned',
      message: 'You have been assigned a new task: ${task.title}',
    );
    save();
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

      final ticket = _tickets.firstWhere((tc) => tc.id == task.ticketId, orElse: () => MockTicket(id: '', title: '', description: '', priority: '', deadline: '', teamId: ''));
      final team = _teams.firstWhere((tm) => tm.id == ticket.teamId, orElse: () => MockTeam(id: '', name: '', managerId: '', leaderId: '', memberIds: []));
      
      if (team.leaderId.isNotEmpty) {
        final memberName = _users.firstWhere((u) => u.id == task.assignedMemberId, orElse: () => MockUser(id: '', email: '', fullName: 'Member', role: '', department: '')).fullName;
        addNotification(
          userId: team.leaderId,
          title: 'Submission Received',
          message: '$memberName submitted the task: ${task.title}',
        );
      }
      save();
    }
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

      final member = _users.firstWhere((u) => u.id == task.assignedMemberId, orElse: () => MockUser(id: '', email: '', fullName: '', role: '', department: ''));
      if (member.id.isNotEmpty) {
        if (status == 'Approved') {
          member.points += 10;
          member.approvalRate = ((member.approvalRate * 9 + 100) / 10).clamp(0.0, 100.0);
          member.points += 5;
          addNotification(
            userId: member.id,
            title: 'Task Approved',
            message: 'Your task "${task.title}" has been approved! (+15 Points)',
          );
        } else if (status == 'Approved With Suggestions') {
          member.points += 7;
          member.approvalRate = ((member.approvalRate * 9 + 100) / 10).clamp(0.0, 100.0);
          addNotification(
            userId: member.id,
            title: 'Task Approved With Suggestions',
            message: 'Your task "${task.title}" was approved with suggestions. (+7 Points)',
          );
        } else if (status == 'Needs Changes') {
          task.status = 'Needs Changes';
          addNotification(
            userId: member.id,
            title: 'Changes Requested',
            message: 'Changes were requested for your task "${task.title}".',
          );
        } else if (status == 'Rejected') {
          member.points -= 10;
          member.rejectionRate = ((member.rejectionRate * 9 + 100) / 10).clamp(0.0, 100.0);
          addNotification(
            userId: member.id,
            title: 'Task Rejected',
            message: 'Your task "${task.title}" has been rejected. (-10 Points)',
          );
        }
        member.recalculateFinalScore();
      }
      
      if (status.startsWith('Approved')) {
        final ticketTasks = _tasks.where((t) => t.ticketId == task.ticketId).toList();
        final completedTasks = ticketTasks.where((t) => t.status == 'Approved' || t.status == 'Approved With Suggestions' || t.status == 'Completed').toList();
        final double progress = ticketTasks.isEmpty ? 0.0 : (completedTasks.length / ticketTasks.length) * 100.0;
        
        final tIdx = _tickets.indexWhere((tc) => tc.id == task.ticketId);
        if (tIdx != -1) {
          _tickets[tIdx].progressPercentage = progress;
          if (progress >= 100.0) {
            _tickets[tIdx].status = 'Completed';
          }
          final teamTickets = _tickets.where((tc) => tc.teamId == _tickets[tIdx].teamId).toList();
          final double teamProgress = teamTickets.isEmpty ? 0.0 : teamTickets.map((tc) => tc.progressPercentage).reduce((a, b) => a + b) / teamTickets.length;
          final tmIdx = _teams.indexWhere((tm) => tm.id == _tickets[tIdx].teamId);
          if (tmIdx != -1) {
            _teams[tmIdx].progress = teamProgress;
          }
        }
      }
      save();
    }
  }

  void addComplaint(MockComplaint complaint) {
    _complaints.add(complaint);
    String notifyTargetRole = 'Admin';
    if (complaint.submitterRole == 'Team Member') {
      notifyTargetRole = 'Team Leader';
    } else if (complaint.submitterRole == 'Team Leader') {
      notifyTargetRole = 'Manager';
    } else if (complaint.submitterRole == 'Manager') {
      notifyTargetRole = 'Admin';
    }

    final targets = _users.where((u) => u.role == notifyTargetRole).toList();
    for (var t in targets) {
      addNotification(
        userId: t.id,
        title: 'New Complaint Submitted',
        message: 'A complaint targeting ${complaint.targetName} was submitted by ${complaint.submitterName}.',
      );
    }
    save();
  }

  void updateComplaintStatus(String complaintId, String status, String notes) {
    final idx = _complaints.indexWhere((c) => c.id == complaintId);
    if (idx != -1) {
      _complaints[idx].status = status;
      _complaints[idx].resolutionNotes = notes;
      
      addNotification(
        userId: _complaints[idx].submitterId,
        title: 'Complaint Update',
        message: 'Your complaint regarding "${_complaints[idx].title}" status changed to: $status',
      );
      save();
    }
  }

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
        date: 'Just now',
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
}
