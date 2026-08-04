import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

extension TranslateExtension on String {
  String tr(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return this;

    switch (this) {
      case 'Dashboard Overview':
        return localizations.dashboardOverview;
      case 'Welcome back':
        return localizations.welcomeBack;
      case 'Language':
        return localizations.language;
      case 'Projects Portfolio':
        return localizations.projectsPortfolio;
      case 'Create and monitor university project developments':
        return localizations.createAndMonitorUniversityProjectDevelopments;
      case 'New Project':
        return localizations.newProject;
      case 'Search projects by name, description...':
        return localizations.searchProjectsByNameDescription;
      case 'Assign Project Manager':
        return localizations.assignProjectManager;
      case 'Select Working Teams':
        return localizations.selectWorkingTeams;
      case 'Priority':
        return localizations.priority;
      case 'Attach Project Files':
        return localizations.attachProjectFiles;
      case 'Click to browse mock files':
        return localizations.clickToBrowseMockFiles;
      case 'Supports PDF, PNG, SQL, DOCX up to 50MB':
        return localizations.supportsPdfPngSqlDocxUpTo50mb;
      case 'Attached Files':
        return localizations.attachedFiles;
      case 'Links (Optional, comma-separated)':
        return localizations.linksOptionalCommaSeparated;
      case 'Manager':
        return localizations.manager;
      case 'Teams':
        return localizations.teams;
      case 'HIGH':
        return localizations.high;
      case 'MEDIUM':
        return localizations.medium;
      case 'LOW':
        return localizations.low;
      case 'In Progress':
        return localizations.inProgress;
      case 'Pending':
        return localizations.pending;
      case 'Completed':
        return localizations.completed;
      case 'Cancel':
        return localizations.cancel;
      case 'Create':
        return localizations.create;
      case 'Close':
        return localizations.close;
      case 'Divide Tasks (Create Tickets)':
        return localizations.divideTasksCreateTickets;
      case 'Divide Tickets into Tasks':
        return localizations.divideTicketsIntoTasks;
      case 'Team Management Portal':
        return localizations.teamManagementPortal;
      case 'Track and filter university team operations & department progress':
        return localizations.trackAndFilterUniversityTeamOperationsDepartmentProgress;
      case 'Add New Team':
        return localizations.addNewTeam;
      case 'Search teams by name or leader...':
        return localizations.searchTeamsByNameOrLeader;
      case 'Team Name':
        return localizations.teamName;
      case 'DEPARTMENT':
        return localizations.department;
      case 'TEAM LEADER':
        return localizations.teamLeader;
      case 'Members':
        return localizations.members;
      case 'Completion Rate':
        return localizations.completionRate;
      case 'ACTIONS':
        return localizations.actions;
      case 'More':
        return localizations.more;
      case 'Create Team':
        return localizations.createTeam;
      case 'Save Changes':
        return localizations.saveChanges;
      case 'Team Supervision':
        return localizations.teamSupervision;
      case 'Back to Teams':
        return localizations.backToTeams;
      case 'Task Score & Completion':
        return localizations.taskScoreCompletion;
      case 'Remaining':
        return localizations.remaining;
      case 'Total Tasks':
        return localizations.totalTasks;
      case 'Active Team Tasks Details':
        return localizations.activeTeamTasksDetails;
      case 'Assigned To':
        return localizations.assignedTo;
      case 'Deadline':
        return localizations.deadline;
      case 'Unassigned':
        return localizations.unassigned;
      case 'Tasks Board':
        return localizations.tasksBoard;
      case 'Tickets Board':
        return localizations.ticketsBoard;
      case 'Monitor, search and filter all assigned task deliverables':
        return localizations.monitorSearchAndFilterAllAssignedTaskDeliverables;
      case 'Monitor, search and filter high-level team deliverables (Tickets)':
        return localizations.monitorSearchAndFilterHighLevelTeamDeliverablesTickets;
      case 'Add Task':
        return localizations.addTask;
      case 'Add Ticket':
        return localizations.addTicket;
      case 'Search tasks or assignees...':
        return localizations.searchTasksOrAssignees;
      case 'Search tickets...':
        return localizations.searchTickets;
      case 'STATUS':
        return localizations.status;
      case 'View Task':
        return localizations.viewTask;
      case 'View Ticket':
        return localizations.viewTicket;
      case 'Submit Work':
        return localizations.submitWork;
      case 'Review':
        return localizations.review;
      case 'View':
        return localizations.view;
      case 'Submit Deliverables':
        return localizations.submitDeliverables;
      case 'Completion Notes':
        return localizations.completionNotes;
      case 'GitHub Repository URL':
        return localizations.githubRepositoryUrl;
      case 'Pull Request URL':
        return localizations.pullRequestUrl;
      case 'Submit':
        return localizations.submit;
      case 'Open':
        return localizations.open;
      case 'Under Review':
        return localizations.underReview;
      case 'Needs Changes':
        return localizations.needsChanges;
      case 'Rejected':
        return localizations.rejected;
      case 'Assigned':
        return localizations.assigned;
      case 'Todo':
        return localizations.todo;
      case 'Users & Roles':
        return localizations.usersRoles;
      case 'Invite User':
        return localizations.inviteUser;
      case 'Total Users':
        return localizations.totalUsers;
      case 'Admins':
        return localizations.admins;
      case 'Managers':
        return localizations.managers;
      case 'Team Leaders':
        return localizations.teamLeaders;
      case 'Team Members':
        return localizations.teamMembers;
      case 'Search users...':
        return localizations.searchUsers;
      case 'Full Name':
        return localizations.fullName;
      case 'Email':
        return localizations.email;
      case 'Role':
        return localizations.role;
      case 'Edit':
        return localizations.edit;
      case 'Delete':
        return localizations.delete;
      case 'Active':
        return localizations.active;
      case 'Disabled':
        return localizations.disabled;
      case 'Invite':
        return localizations.invite;
      case 'Role Selection':
        return localizations.roleSelection;
      case 'Complaints & Investigations':
        return localizations.complaintsInvestigations;
      case 'Submit and track issues, workload, or deadline complaints':
        return localizations.submitAndTrackIssuesWorkloadOrDeadlineComplaints;
      case 'File Complaint':
        return localizations.fileComplaint;
      case 'Search complaints by title...':
        return localizations.searchComplaintsByTitle;
      case 'Submitter':
        return localizations.submitter;
      case 'Target Name':
        return localizations.targetName;
      case 'Complaint Date':
        return localizations.complaintDate;
      case 'Resolution Status':
        return localizations.resolutionStatus;
      case 'Notes / Comments':
        return localizations.notesComments;
      case 'Enter resolution notes or status details...':
        return localizations.enterResolutionNotesOrStatusDetails;
      case 'Update':
        return localizations.update;
      case 'Resolved':
        return localizations.resolved;
      case 'Closed':
        return localizations.closed;
      case 'Escalated':
        return localizations.escalated;
      case 'Evaluation Center':
        return localizations.evaluationCenter;
      case 'Autocalculated weight-based metrics and rankings':
        return localizations.autocalculatedWeightBasedMetricsAndRankings;
      case 'Final Score':
        return localizations.finalScore;
      case 'Points':
        return localizations.points;
      case 'System Performance Reports':
        return localizations.systemPerformanceReports;
      case 'System Health & Metrics':
        return localizations.systemHealthMetrics;
      case 'Delayed Tasks':
        return localizations.delayedTasks;
      case 'Best Submitter':
        return localizations.bestSubmitter;
      case 'Worst Submitter':
        return localizations.worstSubmitter;
      case 'AITU Task Management':
        return localizations.aituTaskManagement;
      case 'Dashboard':
        return localizations.dashboard;
      case 'My Tasks':
        return localizations.myTasks;
      case 'Tasks':
        return localizations.tasks;
      case 'My Tickets':
        return localizations.myTickets;
      case 'Tickets':
        return localizations.tickets;
      case 'Projects':
        return localizations.projects;
      case 'Reports':
        return localizations.reports;
      case 'Profile Settings':
        return localizations.profileSettings;
      case 'Complaints':
        return localizations.complaints;
      case 'Score & Achievements':
        return localizations.scoreAchievements;
      case 'Evaluations':
        return localizations.evaluations;
      case 'Review Center':
        return localizations.reviewCenter;
      case 'Logout':
        return localizations.logout;
      case 'No complaints registered.':
        return localizations.noComplaintsRegistered;
      case 'Mark Resolved':
        return localizations.markResolved;
      case 'Mark Investigating':
        return localizations.markInvestigating;
      case 'Escalate':
        return localizations.escalate;
      case 'Submit a Complaint':
        return localizations.submitAComplaint;
      case 'Complaint Title':
        return localizations.complaintTitle;
      case 'Complaint Target':
        return localizations.complaintTarget;
      case 'Target Identifier / Name':
        return localizations.targetIdentifierName;
      case 'e.g. Sarah Ahmed, Budget Task':
        return localizations.eGSarahAhmedBudgetTask;
      case 'Complaint Details / Context':
        return localizations.complaintDetailsContext;
      case 'Under Investigation':
        return localizations.underInvestigation;
      case 'Update Complaint Status to:':
        return localizations.updateComplaintStatusTo;
      case 'Assign to Team':
        return localizations.assignToTeam;
      case 'Ticket Title':
        return localizations.ticketTitle;
      case 'Description / Requirement':
        return localizations.descriptionRequirement;
      case 'Description':
        return localizations.description;
      case 'Assign':
        return localizations.assign;
      case 'Split Team Tickets:':
        return localizations.splitTeamTickets;
      case 'No active tickets assigned to your team yet.':
        return localizations.noActiveTicketsAssignedToYourTeamYet;
      case 'Split & Assign':
        return localizations.splitAssign;
      case 'Assign Sub-Task for:':
        return localizations.assignSubTaskFor;
      case 'Assign to Member':
        return localizations.assignToMember;
      case 'Sub-Task Title':
        return localizations.subTaskTitle;
      case 'Task Details':
        return localizations.taskDetails;
      case 'USER':
        return localizations.user;
      case 'USERNAME':
        return localizations.username;
      case 'LAST ACTIVE':
        return localizations.lastActive;
      case 'Inactive':
        return localizations.inactive;
      case 'Admin':
        return localizations.admin;
      case 'Team Member':
        return localizations.teamMember;
      case 'Member':
        return localizations.member;
      case 'All':
        return localizations.all;
      case 'Computer Science':
        return localizations.computerScience;
      case 'Engineering':
        return localizations.engineering;
      case 'IT Services':
        return localizations.itServices;
      case 'IT':
        return localizations.it;
      case 'IS':
        return localizations.isKeyword;
      case 'CS':
        return localizations.cs;
      case 'No users found.':
        return localizations.noUsersFound;
      case 'tasks taken':
        return localizations.tasksTaken;
      case 'PROJECT MANAGER':
        return localizations.projectManager;
      case 'Team name is required':
        return localizations.teamNameIsRequired;
      case 'Department is required':
        return localizations.departmentIsRequired;
      case 'Team leader is required':
        return localizations.teamLeaderIsRequired;
      case 'Please select at least one team member.':
        return localizations.pleaseSelectAtLeastOneTeamMember;
      case 'Edit Team':
        return localizations.editTeam;
      case 'Create New Team':
        return localizations.createNewTeam;
      case 'Update team details, leader and members.':
        return localizations.updateTeamDetailsLeaderAndMembers;
      case 'Set up a new team, assign a leader and select members.':
        return localizations.setUpANewTeamAssignALeaderAndSelectMembers;
      case 'Table':
        return localizations.table;
      case 'Kanban':
        return localizations.kanban;
      case 'Calendar':
        return localizations.calendar;
      case 'No tasks matching criteria.':
        return localizations.noTasksMatchingCriteria;
      case 'No tickets matching criteria.':
        return localizations.noTicketsMatchingCriteria;
      case 'Team Rankings (Progress)':
        return localizations.teamRankingsProgress;
      case 'Recent Complaints':
        return localizations.recentComplaints;
      case 'Deliverables Waiting Review':
        return localizations.deliverablesWaitingReview;
      case 'Go to Review Center':
        return localizations.goToReviewCenter;
      case 'No tasks awaiting review.':
        return localizations.noTasksAwaitingReview;
      case 'Project Health Score':
        return localizations.projectHealthScore;
      case 'All systems operational':
        return localizations.allSystemsOperational;
      case 'Weekly Schedule View':
        return localizations.weeklyScheduleView;
      case 'Monday':
        return localizations.monday;
      case 'Tuesday':
        return localizations.tuesday;
      case 'Wednesday':
        return localizations.wednesday;
      case 'Thursday':
        return localizations.thursday;
      case 'Friday':
        return localizations.friday;
      case 'Teams Count':
        return localizations.teamsCount;
      case 'Leaders Count':
        return localizations.leadersCount;
      case 'Projects Count':
        return localizations.projectsCount;
      case 'Progress Percentage':
        return localizations.progressPercentage;
      case 'Team Members Performance':
        return localizations.teamMembersPerformance;
      case 'Score':
        return localizations.score;
      case 'View Evaluation':
        return localizations.viewEvaluation;
      case 'Team Productivity':
        return localizations.teamProductivity;
      case 'Review analytical reports and output metrics':
        return localizations.reviewAnalyticalReportsAndOutputMetrics;
      case 'Export PDF':
        return localizations.exportPdf;
      case 'Export Excel':
        return localizations.exportExcel;
      case 'Print Report':
        return localizations.printReport;
      case 'Custom Range':
        return localizations.customRange;
      case 'Filtering from':
        return localizations.filteringFrom;
      case 'to':
        return localizations.to;
      case 'Best Team':
        return localizations.bestTeam;
      case 'Best Leader':
        return localizations.bestLeader;
      case 'Best Member':
        return localizations.bestMember;
      case 'Best Manager':
        return localizations.bestManager;
      case 'Worst Team':
        return localizations.worstTeam;
      case 'Worst Leader':
        return localizations.worstLeader;
      case 'Worst Member':
        return localizations.worstMember;
      case 'Worst Manager':
        return localizations.worstManager;
      case 'University Task Statistics':
        return localizations.universityTaskStatistics;
      case 'Tasks Approved / Completed':
        return localizations.tasksApprovedCompleted;
      case 'Rejected Submissions':
        return localizations.rejectedSubmissions;
      case 'Complaint Stats':
        return localizations.complaintStats;
      case 'N/A':
        return localizations.nA;
      case 'Exporting Report as':
        return localizations.exportingReportAs;
      case 'Download':
        return localizations.download;
      case 'Successfully downloaded/printed report as':
        return localizations.successfullyDownloadedPrintedReportAs;
      case 'of':
        return localizations.ofKeyword;
      case 'Day':
        return localizations.day;
      case 'Week':
        return localizations.week;
      case 'Month':
        return localizations.month;
      case 'Year':
        return localizations.year;
      case 'Start Date':
        return localizations.startDate;
      case 'Start Time':
        return localizations.startTime;
      case 'Due Date':
        return localizations.dueDate;
      case 'Due Time':
        return localizations.dueTime;
      case 'Estimated Duration (Hours)':
        return localizations.estimatedDurationHours;
      case 'Allow Reassignment':
        return localizations.allowReassignment;
      case 'Assigned By':
        return localizations.assignedBy;
      case 'Current Owner':
        return localizations.currentOwner;
      case 'Remaining Time':
        return localizations.remainingTime;
      case 'Progress':
        return localizations.progress;
      case 'Delegate':
        return localizations.delegateKeyword;
      case 'Weekly Progress':
        return localizations.weeklyProgress;
      case 'Department Performance':
        return localizations.departmentPerformance;
      case 'Priority Distribution':
        return localizations.priorityDistribution;
      case 'Upcoming Deadlines':
        return localizations.upcomingDeadlines;
      case 'Recent Activity':
        return localizations.recentActivity;
      case 'Task Status':
        return localizations.taskStatus;
      case 'Assignment Mode':
        return localizations.assignmentMode;
      case 'Individual':
        return localizations.individual;
      case 'Team':
        return localizations.team;
      case 'Select User':
        return localizations.selectUser;
      case 'Select Team':
        return localizations.selectTeam;
      case 'Select Department':
        return localizations.selectDepartment;
      case 'Delegate Task':
        return localizations.delegateTask;
      case 'Delegate To':
        return localizations.delegateTo;
      case 'Task Information':
        return localizations.taskInformation;
      case 'Start Date & Time':
        return localizations.startDateAndTime;
      case 'Due Date & Time':
        return localizations.dueDateAndTime;
      case 'Attachments':
        return localizations.attachments;
      case 'Assignment':
        return localizations.assignment;
      case 'Task Creator':
        return localizations.taskCreator;
      case 'Delegate Workflow':
        return localizations.delegateWorkflow;
      case 'Estimated Duration':
        return localizations.estimatedDuration;
      case 'Custom Date Range':
        return localizations.customDateRange;
      case 'Overdue':
        return localizations.overdue;
      case 'Ascending':
        return localizations.ascending;
      case 'Descending':
        return localizations.descending;
      case 'Newest':
        return localizations.newest;
      case 'Oldest':
        return localizations.oldest;
      case 'Sort By':
        return localizations.sortBy;
      case 'Filter Bar':
        return localizations.filterBar;
      case 'Date Range':
        return localizations.dateRange;
      case 'Search':
        return localizations.search;
      case 'Department':
        return localizations.departmentVal;
      case 'Total Employees':
        return localizations.totalEmployees;
      case 'Total Departments':
        return localizations.totalDepartments;
      case 'Open Complaints':
        return localizations.openComplaints;
      case 'Average Performance Score':
        return localizations.averagePerformanceScore;
      case 'Task Status Distribution':
        return localizations.taskStatusDistribution;
      case 'Weekly Completion Trend':
        return localizations.weeklyCompletionTrend;
      case 'Monthly Performance Trend':
        return localizations.monthlyPerformanceTrend;
      case 'Employee Performance Ranking':
        return localizations.employeePerformanceRanking;
      case 'Latest Complaints':
        return localizations.latestComplaints;
      case 'Top Employees':
        return localizations.topEmployees;
      case 'Most Delayed Employees':
        return localizations.mostDelayedEmployees;
      case 'Task Checklist':
        return localizations.taskChecklist;
      case 'Time Tracking':
        return localizations.timeTracking;
      case 'Estimated Time':
        return localizations.estimatedTime;
      case 'Actual Time':
        return localizations.actualTime;
      case 'Start':
        return localizations.start;
      case 'Pause':
        return localizations.pause;
      case 'Resume':
        return localizations.resume;
      case 'Stop':
        return localizations.stop;
      case 'Overview':
        return localizations.overview;
      case 'Discussion':
        return localizations.discussion;
      case 'Activity Timeline':
        return localizations.activityTimeline;
      case 'History':
        return localizations.history;
      case 'Audit Log':
        return localizations.auditLog;
      case 'Executive Summary':
        return localizations.executiveSummary;
      case 'Completion Rate %':
        return localizations.completionRatePct;
      case 'Average Completion Time':
        return localizations.averageCompletionTime;
      case 'Users':
        return localizations.users;
      case 'Departments':
        return localizations.departments;
      case 'Roles':
        return localizations.roles;
      case 'Audit Logs':
        return localizations.auditLogs;
      case 'Add Department':
        return localizations.addDepartment;
      case 'Edit Department':
        return localizations.editDepartment;
      case 'Delete Department':
        return localizations.deleteDepartment;
      case 'Manage Roles':
        return localizations.manageRoles;
      case 'Manage Permissions':
        return localizations.managePermissions;
      case 'Task Type':
        return localizations.taskType;
      case 'Individual Task':
        return localizations.individualTask;
      case 'Team Task':
        return localizations.teamTask;
      case 'Add User':
        return localizations.addUser;
      case 'Edit User':
        return localizations.editUser;
      case 'Delete User':
        return localizations.deleteUser;
      case 'Code':
        return localizations.code;
      case 'Permissions':
        return localizations.permissions;
      case 'Closed By':
        return localizations.closedBy;
      case 'Closed Date':
        return localizations.closedDate;
      case 'Investigation Notes':
        return localizations.investigationNotes;
      case 'Resolution':
        return localizations.resolution;
      case 'Corrective Action':
        return localizations.correctiveAction;
      case 'Warning':
        return localizations.warning;
      case 'Training Required':
        return localizations.trainingRequired;
      case 'Performance Evaluation':
        return localizations.performanceEvaluation;
      case 'Task Quality':
        return localizations.taskQuality;
      case 'Communication':
        return localizations.communication;
      case 'Teamwork':
        return localizations.teamwork;
      case 'Discipline':
        return localizations.discipline;
      case 'Problem Solving':
        return localizations.problemSolving;
      case 'Deadline Commitment':
        return localizations.deadlineCommitment;
      case 'Overall Score':
        return localizations.overallScore;
      case 'Average Rating':
        return localizations.averageRating;
      case 'Completed Tasks':
        return localizations.completedTasks;
      case 'Overdue Tasks':
        return localizations.overdueTasks;
      case 'Complaints Count':
        return localizations.complaintsCount;
      case 'Evaluation History':
        return localizations.evaluationHistory;
      case 'Manager Notes':
        return localizations.managerNotes;
      case 'Recommendations':
        return localizations.recommendations;
      case 'Module':
        return localizations.module;
      case 'Operation':
        return localizations.operation;
      case 'Global Search':
        return localizations.globalSearch;
      case 'Breadcrumb':
        return localizations.breadcrumb;
      case 'Profile Menu':
        return localizations.profileMenu;
      case '360° Employee Overview':
        return localizations.employeeOverview360;
      case 'View Full Details':
        return localizations.viewFullDetails;
      case 'Print':
        return localizations.print;
      case 'Upload Files':
        return localizations.uploadFiles;
      case 'Selected Files':
        return localizations.selectedFiles;
      case 'Send Notes':
        return localizations.sendNotes;
      case 'Send Deliverables':
        return localizations.sendDeliverables;
      case 'Tap to choose files':
        return localizations.tapToChooseFiles;
      case 'Any file type is supported (images, PDFs, zip, code...)':
        return localizations.anyFileTypeSupported;
      case 'Attach any file type to help solve this task.':
        return localizations.attachAnyFileTypeToHelpSolveThisTask;
      case 'Add a note or message to help solve this task.':
        return localizations.addNoteOrMessageToHelpSolveThisTask;
      case 'Write a note, explain your solution, or describe what you need...':
        return localizations.writeNoteExplainSolutionOrDescribeWhatYouNeed;
      case 'Please attach a file or write a note first':
        return localizations.pleaseAttachAFileOrWriteANoteFirst;
      case 'Deliverables sent successfully':
        return localizations.deliverablesSentSuccessfully;
      case 'Team Leader Actions':
        return localizations.teamLeaderActions;
      case 'Submit for Review':
        return localizations.submitForReview;
      case 'Review Deliverable':
        return localizations.reviewDeliverable;
      case 'Enter review feedback...':
        return localizations.enterReviewFeedback;
      case 'Approve':
        return localizations.approve;
      case 'Approve & Complete':
        return localizations.approveAndComplete;
      case 'Reject':
        return localizations.reject;
      case 'Edit Task':
        return localizations.editTask;
      case 'Reassign':
        return localizations.reassign;
      case 'Reassign Task':
        return localizations.reassignTask;
      case 'Select Team Member':
        return localizations.selectTeamMember;
      case 'Choose member...':
        return localizations.chooseMember;
      case 'Task reassigned successfully':
        return localizations.taskReassignedSuccessfully;
      case 'Task updated successfully':
        return localizations.taskUpdatedSuccessfully;
      case 'Save':
        return localizations.save;
      case 'Current Status':
        return localizations.currentStatus;
      case 'My Complaints':
        return localizations.myComplaints;
      case 'Track and manage your submitted complaints':
        return localizations.trackAndManageYourSubmittedComplaints;
      case 'Total':
        return localizations.total;
      case 'Complaint Analytics':
        return localizations.complaintAnalytics;
      case 'Your complaint is pending review.':
        return localizations.complaintPendingReview;
      case 'This complaint has been closed.':
        return localizations.complaintClosed;
      default:
        return this;
    }
  }
}
