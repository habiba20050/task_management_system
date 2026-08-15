import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardOverview;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @projectsPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Projects Portfolio'**
  String get projectsPortfolio;

  /// No description provided for @createAndMonitorUniversityProjectDevelopments.
  ///
  /// In en, this message translates to:
  /// **'Create and monitor university project developments'**
  String get createAndMonitorUniversityProjectDevelopments;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @searchProjectsByNameDescription.
  ///
  /// In en, this message translates to:
  /// **'Search projects by name, description...'**
  String get searchProjectsByNameDescription;

  /// No description provided for @assignProjectManager.
  ///
  /// In en, this message translates to:
  /// **'Assign Project Manager'**
  String get assignProjectManager;

  /// No description provided for @selectWorkingTeams.
  ///
  /// In en, this message translates to:
  /// **'Select Working Teams'**
  String get selectWorkingTeams;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @attachProjectFiles.
  ///
  /// In en, this message translates to:
  /// **'Attach Project Files'**
  String get attachProjectFiles;

  /// No description provided for @clickToBrowseMockFiles.
  ///
  /// In en, this message translates to:
  /// **'Click to browse mock files'**
  String get clickToBrowseMockFiles;

  /// No description provided for @supportsPdfPngSqlDocxUpTo50mb.
  ///
  /// In en, this message translates to:
  /// **'Supports PDF, PNG, SQL, DOCX up to 50MB'**
  String get supportsPdfPngSqlDocxUpTo50mb;

  /// No description provided for @attachedFiles.
  ///
  /// In en, this message translates to:
  /// **'Attached Files'**
  String get attachedFiles;

  /// No description provided for @linksOptionalCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Links (Optional, comma-separated)'**
  String get linksOptionalCommaSeparated;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get low;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @divideTasksCreateTickets.
  ///
  /// In en, this message translates to:
  /// **'Divide Tasks (Create Tickets)'**
  String get divideTasksCreateTickets;

  /// No description provided for @divideTicketsIntoTasks.
  ///
  /// In en, this message translates to:
  /// **'Divide Tickets into Tasks'**
  String get divideTicketsIntoTasks;

  /// No description provided for @teamManagementPortal.
  ///
  /// In en, this message translates to:
  /// **'Team Management Portal'**
  String get teamManagementPortal;

  /// No description provided for @trackAndFilterUniversityTeamOperationsDepartmentProgress.
  ///
  /// In en, this message translates to:
  /// **'Track and filter university team operations & department progress'**
  String get trackAndFilterUniversityTeamOperationsDepartmentProgress;

  /// No description provided for @addNewTeam.
  ///
  /// In en, this message translates to:
  /// **'Add New Team'**
  String get addNewTeam;

  /// No description provided for @searchTeamsByNameOrLeader.
  ///
  /// In en, this message translates to:
  /// **'Search teams by name or leader...'**
  String get searchTeamsByNameOrLeader;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get teamName;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'DEPARTMENT'**
  String get department;

  /// No description provided for @teamLeader.
  ///
  /// In en, this message translates to:
  /// **'TEAM LEADER'**
  String get teamLeader;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actions;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeam;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @teamSupervision.
  ///
  /// In en, this message translates to:
  /// **'Team Supervision'**
  String get teamSupervision;

  /// No description provided for @backToTeams.
  ///
  /// In en, this message translates to:
  /// **'Back to Teams'**
  String get backToTeams;

  /// No description provided for @taskScoreCompletion.
  ///
  /// In en, this message translates to:
  /// **'Task Score & Completion'**
  String get taskScoreCompletion;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @totalTasks.
  ///
  /// In en, this message translates to:
  /// **'Total Tasks'**
  String get totalTasks;

  /// No description provided for @activeTeamTasksDetails.
  ///
  /// In en, this message translates to:
  /// **'Active Team Tasks Details'**
  String get activeTeamTasksDetails;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assignedTo;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @tasksBoard.
  ///
  /// In en, this message translates to:
  /// **'Tasks Board'**
  String get tasksBoard;

  /// No description provided for @ticketsBoard.
  ///
  /// In en, this message translates to:
  /// **'Tickets Board'**
  String get ticketsBoard;

  /// No description provided for @monitorSearchAndFilterAllAssignedTaskDeliverables.
  ///
  /// In en, this message translates to:
  /// **'Monitor, search and filter all assigned task deliverables'**
  String get monitorSearchAndFilterAllAssignedTaskDeliverables;

  /// No description provided for @monitorSearchAndFilterHighLevelTeamDeliverablesTickets.
  ///
  /// In en, this message translates to:
  /// **'Monitor, search and filter high-level team deliverables (Tickets)'**
  String get monitorSearchAndFilterHighLevelTeamDeliverablesTickets;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @addTicket.
  ///
  /// In en, this message translates to:
  /// **'Add Ticket'**
  String get addTicket;

  /// No description provided for @searchTasksOrAssignees.
  ///
  /// In en, this message translates to:
  /// **'Search tasks or assignees...'**
  String get searchTasksOrAssignees;

  /// No description provided for @searchTickets.
  ///
  /// In en, this message translates to:
  /// **'Search tickets...'**
  String get searchTickets;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get status;

  /// No description provided for @viewTask.
  ///
  /// In en, this message translates to:
  /// **'View Task'**
  String get viewTask;

  /// No description provided for @viewTicket.
  ///
  /// In en, this message translates to:
  /// **'View Ticket'**
  String get viewTicket;

  /// No description provided for @submitWork.
  ///
  /// In en, this message translates to:
  /// **'Submit Work'**
  String get submitWork;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @submitDeliverables.
  ///
  /// In en, this message translates to:
  /// **'Submit Deliverables'**
  String get submitDeliverables;

  /// No description provided for @completionNotes.
  ///
  /// In en, this message translates to:
  /// **'Completion Notes'**
  String get completionNotes;

  /// No description provided for @githubRepositoryUrl.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository URL'**
  String get githubRepositoryUrl;

  /// No description provided for @pullRequestUrl.
  ///
  /// In en, this message translates to:
  /// **'Pull Request URL'**
  String get pullRequestUrl;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @needsChanges.
  ///
  /// In en, this message translates to:
  /// **'Needs Changes'**
  String get needsChanges;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @todo.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get todo;

  /// No description provided for @usersRoles.
  ///
  /// In en, this message translates to:
  /// **'Users & Roles'**
  String get usersRoles;

  /// No description provided for @inviteUser.
  ///
  /// In en, this message translates to:
  /// **'Invite User'**
  String get inviteUser;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalTeams.
  ///
  /// In en, this message translates to:
  /// **'Total Teams'**
  String get totalTeams;

  /// No description provided for @organizationOverview.
  ///
  /// In en, this message translates to:
  /// **'Organization Overview'**
  String get organizationOverview;

  /// No description provided for @departmentSummary.
  ///
  /// In en, this message translates to:
  /// **'Department Summary'**
  String get departmentSummary;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @managers.
  ///
  /// In en, this message translates to:
  /// **'Managers'**
  String get managers;

  /// No description provided for @teamLeaders.
  ///
  /// In en, this message translates to:
  /// **'Team Leaders'**
  String get teamLeaders;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @roleSelection.
  ///
  /// In en, this message translates to:
  /// **'Role Selection'**
  String get roleSelection;

  /// No description provided for @complaintsInvestigations.
  ///
  /// In en, this message translates to:
  /// **'Complaints & Investigations'**
  String get complaintsInvestigations;

  /// No description provided for @submitAndTrackIssuesWorkloadOrDeadlineComplaints.
  ///
  /// In en, this message translates to:
  /// **'Submit and track issues, workload, or deadline complaints'**
  String get submitAndTrackIssuesWorkloadOrDeadlineComplaints;

  /// No description provided for @fileComplaint.
  ///
  /// In en, this message translates to:
  /// **'File Complaint'**
  String get fileComplaint;

  /// No description provided for @searchComplaintsByTitle.
  ///
  /// In en, this message translates to:
  /// **'Search complaints by title...'**
  String get searchComplaintsByTitle;

  /// No description provided for @submitter.
  ///
  /// In en, this message translates to:
  /// **'Submitter'**
  String get submitter;

  /// No description provided for @targetName.
  ///
  /// In en, this message translates to:
  /// **'Target Name'**
  String get targetName;

  /// No description provided for @complaintDate.
  ///
  /// In en, this message translates to:
  /// **'Complaint Date'**
  String get complaintDate;

  /// No description provided for @resolutionStatus.
  ///
  /// In en, this message translates to:
  /// **'Resolution Status'**
  String get resolutionStatus;

  /// No description provided for @notesComments.
  ///
  /// In en, this message translates to:
  /// **'Notes / Comments'**
  String get notesComments;

  /// No description provided for @enterResolutionNotesOrStatusDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter resolution notes or status details...'**
  String get enterResolutionNotesOrStatusDetails;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @escalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get escalated;

  /// No description provided for @evaluationCenter.
  ///
  /// In en, this message translates to:
  /// **'Evaluation Center'**
  String get evaluationCenter;

  /// No description provided for @autocalculatedWeightBasedMetricsAndRankings.
  ///
  /// In en, this message translates to:
  /// **'Autocalculated weight-based metrics and rankings'**
  String get autocalculatedWeightBasedMetricsAndRankings;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @systemPerformanceReports.
  ///
  /// In en, this message translates to:
  /// **'System Performance Reports'**
  String get systemPerformanceReports;

  /// No description provided for @systemHealthMetrics.
  ///
  /// In en, this message translates to:
  /// **'System Health & Metrics'**
  String get systemHealthMetrics;

  /// No description provided for @delayedTasks.
  ///
  /// In en, this message translates to:
  /// **'Delayed Tasks'**
  String get delayedTasks;

  /// No description provided for @bestSubmitter.
  ///
  /// In en, this message translates to:
  /// **'Best Submitter'**
  String get bestSubmitter;

  /// No description provided for @worstSubmitter.
  ///
  /// In en, this message translates to:
  /// **'Worst Submitter'**
  String get worstSubmitter;

  /// No description provided for @aituTaskManagement.
  ///
  /// In en, this message translates to:
  /// **'AITU Task Management'**
  String get aituTaskManagement;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @scoreAchievements.
  ///
  /// In en, this message translates to:
  /// **'Score & Achievements'**
  String get scoreAchievements;

  /// No description provided for @evaluations.
  ///
  /// In en, this message translates to:
  /// **'Evaluations'**
  String get evaluations;

  /// No description provided for @reviewCenter.
  ///
  /// In en, this message translates to:
  /// **'Review Center'**
  String get reviewCenter;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @noComplaintsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No complaints registered.'**
  String get noComplaintsRegistered;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get markResolved;

  /// No description provided for @markInvestigating.
  ///
  /// In en, this message translates to:
  /// **'Mark Investigating'**
  String get markInvestigating;

  /// No description provided for @escalate.
  ///
  /// In en, this message translates to:
  /// **'Escalate'**
  String get escalate;

  /// No description provided for @submitAComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit a Complaint'**
  String get submitAComplaint;

  /// No description provided for @complaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint Title'**
  String get complaintTitle;

  /// No description provided for @complaintTarget.
  ///
  /// In en, this message translates to:
  /// **'Complaint Target'**
  String get complaintTarget;

  /// No description provided for @targetIdentifierName.
  ///
  /// In en, this message translates to:
  /// **'Target Identifier / Name'**
  String get targetIdentifierName;

  /// No description provided for @eGSarahAhmedBudgetTask.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sarah Ahmed, Budget Task'**
  String get eGSarahAhmedBudgetTask;

  /// No description provided for @complaintDetailsContext.
  ///
  /// In en, this message translates to:
  /// **'Complaint Details / Context'**
  String get complaintDetailsContext;

  /// No description provided for @underInvestigation.
  ///
  /// In en, this message translates to:
  /// **'Under Investigation'**
  String get underInvestigation;

  /// No description provided for @updateComplaintStatusTo.
  ///
  /// In en, this message translates to:
  /// **'Update Complaint Status to:'**
  String get updateComplaintStatusTo;

  /// No description provided for @assignToTeam.
  ///
  /// In en, this message translates to:
  /// **'Assign to Team'**
  String get assignToTeam;

  /// No description provided for @ticketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Title'**
  String get ticketTitle;

  /// No description provided for @descriptionRequirement.
  ///
  /// In en, this message translates to:
  /// **'Description / Requirement'**
  String get descriptionRequirement;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @splitTeamTickets.
  ///
  /// In en, this message translates to:
  /// **'Split Team Tickets:'**
  String get splitTeamTickets;

  /// No description provided for @noActiveTicketsAssignedToYourTeamYet.
  ///
  /// In en, this message translates to:
  /// **'No active tickets assigned to your team yet.'**
  String get noActiveTicketsAssignedToYourTeamYet;

  /// No description provided for @splitAssign.
  ///
  /// In en, this message translates to:
  /// **'Split & Assign'**
  String get splitAssign;

  /// No description provided for @assignSubTaskFor.
  ///
  /// In en, this message translates to:
  /// **'Assign Sub-Task for:'**
  String get assignSubTaskFor;

  /// No description provided for @assignToMember.
  ///
  /// In en, this message translates to:
  /// **'Assign to Member'**
  String get assignToMember;

  /// No description provided for @subTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Sub-Task Title'**
  String get subTaskTitle;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'USER'**
  String get user;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get username;

  /// No description provided for @lastActive.
  ///
  /// In en, this message translates to:
  /// **'LAST ACTIVE'**
  String get lastActive;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @teamMember.
  ///
  /// In en, this message translates to:
  /// **'Team Member'**
  String get teamMember;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @computerScience.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get computerScience;

  /// No description provided for @engineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get engineering;

  /// No description provided for @itServices.
  ///
  /// In en, this message translates to:
  /// **'IT Services'**
  String get itServices;

  /// No description provided for @it.
  ///
  /// In en, this message translates to:
  /// **'IT'**
  String get it;

  /// No description provided for @isKeyword.
  ///
  /// In en, this message translates to:
  /// **'IS'**
  String get isKeyword;

  /// No description provided for @cs.
  ///
  /// In en, this message translates to:
  /// **'CS'**
  String get cs;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @tasksTaken.
  ///
  /// In en, this message translates to:
  /// **'tasks taken'**
  String get tasksTaken;

  /// No description provided for @projectManager.
  ///
  /// In en, this message translates to:
  /// **'PROJECT MANAGER'**
  String get projectManager;

  /// No description provided for @teamNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Team name is required'**
  String get teamNameIsRequired;

  /// No description provided for @departmentIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Department is required'**
  String get departmentIsRequired;

  /// No description provided for @teamLeaderIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Team leader is required'**
  String get teamLeaderIsRequired;

  /// No description provided for @pleaseSelectAtLeastOneTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one team member.'**
  String get pleaseSelectAtLeastOneTeamMember;

  /// No description provided for @editTeam.
  ///
  /// In en, this message translates to:
  /// **'Edit Team'**
  String get editTeam;

  /// No description provided for @createNewTeam.
  ///
  /// In en, this message translates to:
  /// **'Create New Team'**
  String get createNewTeam;

  /// No description provided for @updateTeamDetailsLeaderAndMembers.
  ///
  /// In en, this message translates to:
  /// **'Update team details, leader and members.'**
  String get updateTeamDetailsLeaderAndMembers;

  /// No description provided for @setUpANewTeamAssignALeaderAndSelectMembers.
  ///
  /// In en, this message translates to:
  /// **'Set up a new team, assign a leader and select members.'**
  String get setUpANewTeamAssignALeaderAndSelectMembers;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @kanban.
  ///
  /// In en, this message translates to:
  /// **'Kanban'**
  String get kanban;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @noTasksMatchingCriteria.
  ///
  /// In en, this message translates to:
  /// **'No tasks matching criteria.'**
  String get noTasksMatchingCriteria;

  /// No description provided for @noTicketsMatchingCriteria.
  ///
  /// In en, this message translates to:
  /// **'No tickets matching criteria.'**
  String get noTicketsMatchingCriteria;

  /// No description provided for @teamRankingsProgress.
  ///
  /// In en, this message translates to:
  /// **'Team Rankings (Progress)'**
  String get teamRankingsProgress;

  /// No description provided for @recentComplaints.
  ///
  /// In en, this message translates to:
  /// **'Recent Complaints'**
  String get recentComplaints;

  /// No description provided for @deliverablesWaitingReview.
  ///
  /// In en, this message translates to:
  /// **'Deliverables Waiting Review'**
  String get deliverablesWaitingReview;

  /// No description provided for @goToReviewCenter.
  ///
  /// In en, this message translates to:
  /// **'Go to Review Center'**
  String get goToReviewCenter;

  /// No description provided for @noTasksAwaitingReview.
  ///
  /// In en, this message translates to:
  /// **'No tasks awaiting review.'**
  String get noTasksAwaitingReview;

  /// No description provided for @projectHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Project Health Score'**
  String get projectHealthScore;

  /// No description provided for @allSystemsOperational.
  ///
  /// In en, this message translates to:
  /// **'All systems operational'**
  String get allSystemsOperational;

  /// No description provided for @weeklyScheduleView.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule View'**
  String get weeklyScheduleView;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @teamsCount.
  ///
  /// In en, this message translates to:
  /// **'Teams Count'**
  String get teamsCount;

  /// No description provided for @leadersCount.
  ///
  /// In en, this message translates to:
  /// **'Leaders Count'**
  String get leadersCount;

  /// No description provided for @projectsCount.
  ///
  /// In en, this message translates to:
  /// **'Projects Count'**
  String get projectsCount;

  /// No description provided for @progressPercentage.
  ///
  /// In en, this message translates to:
  /// **'Progress Percentage'**
  String get progressPercentage;

  /// No description provided for @teamMembersPerformance.
  ///
  /// In en, this message translates to:
  /// **'Team Members Performance'**
  String get teamMembersPerformance;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @viewEvaluation.
  ///
  /// In en, this message translates to:
  /// **'View Evaluation'**
  String get viewEvaluation;

  /// No description provided for @teamProductivity.
  ///
  /// In en, this message translates to:
  /// **'Team Productivity'**
  String get teamProductivity;

  /// No description provided for @reviewAnalyticalReportsAndOutputMetrics.
  ///
  /// In en, this message translates to:
  /// **'Review analytical reports and output metrics'**
  String get reviewAnalyticalReportsAndOutputMetrics;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @printReport.
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get printReport;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @filteringFrom.
  ///
  /// In en, this message translates to:
  /// **'Filtering from'**
  String get filteringFrom;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @bestTeam.
  ///
  /// In en, this message translates to:
  /// **'Best Team'**
  String get bestTeam;

  /// No description provided for @bestLeader.
  ///
  /// In en, this message translates to:
  /// **'Best Leader'**
  String get bestLeader;

  /// No description provided for @bestMember.
  ///
  /// In en, this message translates to:
  /// **'Best Member'**
  String get bestMember;

  /// No description provided for @bestManager.
  ///
  /// In en, this message translates to:
  /// **'Best Manager'**
  String get bestManager;

  /// No description provided for @worstTeam.
  ///
  /// In en, this message translates to:
  /// **'Worst Team'**
  String get worstTeam;

  /// No description provided for @worstLeader.
  ///
  /// In en, this message translates to:
  /// **'Worst Leader'**
  String get worstLeader;

  /// No description provided for @worstMember.
  ///
  /// In en, this message translates to:
  /// **'Worst Member'**
  String get worstMember;

  /// No description provided for @worstManager.
  ///
  /// In en, this message translates to:
  /// **'Worst Manager'**
  String get worstManager;

  /// No description provided for @universityTaskStatistics.
  ///
  /// In en, this message translates to:
  /// **'University Task Statistics'**
  String get universityTaskStatistics;

  /// No description provided for @tasksApprovedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tasks Approved / Completed'**
  String get tasksApprovedCompleted;

  /// No description provided for @rejectedSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Rejected Submissions'**
  String get rejectedSubmissions;

  /// No description provided for @complaintStats.
  ///
  /// In en, this message translates to:
  /// **'Complaint Stats'**
  String get complaintStats;

  /// No description provided for @nA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get nA;

  /// No description provided for @exportingReportAs.
  ///
  /// In en, this message translates to:
  /// **'Exporting Report as'**
  String get exportingReportAs;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @successfullyDownloadedPrintedReportAs.
  ///
  /// In en, this message translates to:
  /// **'Successfully downloaded/printed report as'**
  String get successfullyDownloadedPrintedReportAs;

  /// No description provided for @ofKeyword.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofKeyword;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @dueTime.
  ///
  /// In en, this message translates to:
  /// **'Due Time'**
  String get dueTime;

  /// No description provided for @estimatedDurationHours.
  ///
  /// In en, this message translates to:
  /// **'Estimated Duration (Hours)'**
  String get estimatedDurationHours;

  /// No description provided for @allowReassignment.
  ///
  /// In en, this message translates to:
  /// **'Allow Reassignment'**
  String get allowReassignment;

  /// No description provided for @assignedBy.
  ///
  /// In en, this message translates to:
  /// **'Assigned By'**
  String get assignedBy;

  /// No description provided for @currentOwner.
  ///
  /// In en, this message translates to:
  /// **'Current Owner'**
  String get currentOwner;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining Time'**
  String get remainingTime;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @delegateKeyword.
  ///
  /// In en, this message translates to:
  /// **'Delegate'**
  String get delegateKeyword;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @departmentPerformance.
  ///
  /// In en, this message translates to:
  /// **'Department Performance'**
  String get departmentPerformance;

  /// No description provided for @priorityDistribution.
  ///
  /// In en, this message translates to:
  /// **'Priority Distribution'**
  String get priorityDistribution;

  /// No description provided for @upcomingDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Deadlines'**
  String get upcomingDeadlines;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @taskStatus.
  ///
  /// In en, this message translates to:
  /// **'Task Status'**
  String get taskStatus;

  /// No description provided for @assignmentMode.
  ///
  /// In en, this message translates to:
  /// **'Assignment Mode'**
  String get assignmentMode;

  /// No description provided for @userType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @teamScope.
  ///
  /// In en, this message translates to:
  /// **'Team Scope'**
  String get teamScope;

  /// No description provided for @forWhom.
  ///
  /// In en, this message translates to:
  /// **'For Whom'**
  String get forWhom;

  /// No description provided for @wholeTeam.
  ///
  /// In en, this message translates to:
  /// **'Whole Team'**
  String get wholeTeam;

  /// No description provided for @specificPerson.
  ///
  /// In en, this message translates to:
  /// **'Specific Person'**
  String get specificPerson;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @selectUser.
  ///
  /// In en, this message translates to:
  /// **'Select User'**
  String get selectUser;

  /// No description provided for @selectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select Team'**
  String get selectTeam;

  /// No description provided for @selectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Select Department'**
  String get selectDepartment;

  /// No description provided for @delegateTask.
  ///
  /// In en, this message translates to:
  /// **'Delegate Task'**
  String get delegateTask;

  /// No description provided for @delegateTo.
  ///
  /// In en, this message translates to:
  /// **'Delegate To'**
  String get delegateTo;

  /// No description provided for @taskInformation.
  ///
  /// In en, this message translates to:
  /// **'Task Information'**
  String get taskInformation;

  /// No description provided for @startDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Start Date & Time'**
  String get startDateAndTime;

  /// No description provided for @dueDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Due Date & Time'**
  String get dueDateAndTime;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @assignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get assignment;

  /// No description provided for @taskCreator.
  ///
  /// In en, this message translates to:
  /// **'Task Creator'**
  String get taskCreator;

  /// No description provided for @delegateWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Delegate Workflow'**
  String get delegateWorkflow;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated Duration'**
  String get estimatedDuration;

  /// No description provided for @customDateRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Date Range'**
  String get customDateRange;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @filterBar.
  ///
  /// In en, this message translates to:
  /// **'Filter Bar'**
  String get filterBar;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @departmentVal.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get departmentVal;

  /// No description provided for @totalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total Employees'**
  String get totalEmployees;

  /// No description provided for @totalDepartments.
  ///
  /// In en, this message translates to:
  /// **'Total Departments'**
  String get totalDepartments;

  /// No description provided for @openComplaints.
  ///
  /// In en, this message translates to:
  /// **'Open Complaints'**
  String get openComplaints;

  /// No description provided for @averagePerformanceScore.
  ///
  /// In en, this message translates to:
  /// **'Average Performance Score'**
  String get averagePerformanceScore;

  /// No description provided for @taskStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Task Status Distribution'**
  String get taskStatusDistribution;

  /// No description provided for @weeklyCompletionTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Completion Trend'**
  String get weeklyCompletionTrend;

  /// No description provided for @monthlyPerformanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Performance Trend'**
  String get monthlyPerformanceTrend;

  /// No description provided for @employeePerformanceRanking.
  ///
  /// In en, this message translates to:
  /// **'Employee Performance Ranking'**
  String get employeePerformanceRanking;

  /// No description provided for @latestComplaints.
  ///
  /// In en, this message translates to:
  /// **'Latest Complaints'**
  String get latestComplaints;

  /// No description provided for @topEmployees.
  ///
  /// In en, this message translates to:
  /// **'Top Employees'**
  String get topEmployees;

  /// No description provided for @mostDelayedEmployees.
  ///
  /// In en, this message translates to:
  /// **'Most Delayed Employees'**
  String get mostDelayedEmployees;

  /// No description provided for @taskChecklist.
  ///
  /// In en, this message translates to:
  /// **'Task Checklist'**
  String get taskChecklist;

  /// No description provided for @timeTracking.
  ///
  /// In en, this message translates to:
  /// **'Time Tracking'**
  String get timeTracking;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @actualTime.
  ///
  /// In en, this message translates to:
  /// **'Actual Time'**
  String get actualTime;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @discussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// No description provided for @activityTimeline.
  ///
  /// In en, this message translates to:
  /// **'Activity Timeline'**
  String get activityTimeline;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// No description provided for @executiveSummary.
  ///
  /// In en, this message translates to:
  /// **'Executive Summary'**
  String get executiveSummary;

  /// No description provided for @completionRatePct.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate %'**
  String get completionRatePct;

  /// No description provided for @averageCompletionTime.
  ///
  /// In en, this message translates to:
  /// **'Average Completion Time'**
  String get averageCompletionTime;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @auditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get auditLogs;

  /// No description provided for @addDepartment.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get addDepartment;

  /// No description provided for @editDepartment.
  ///
  /// In en, this message translates to:
  /// **'Edit Department'**
  String get editDepartment;

  /// No description provided for @deleteDepartment.
  ///
  /// In en, this message translates to:
  /// **'Delete Department'**
  String get deleteDepartment;

  /// No description provided for @manageRoles.
  ///
  /// In en, this message translates to:
  /// **'Manage Roles'**
  String get manageRoles;

  /// No description provided for @managePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get managePermissions;

  /// No description provided for @taskType.
  ///
  /// In en, this message translates to:
  /// **'Task Type'**
  String get taskType;

  /// No description provided for @individualTask.
  ///
  /// In en, this message translates to:
  /// **'Individual Task'**
  String get individualTask;

  /// No description provided for @teamTask.
  ///
  /// In en, this message translates to:
  /// **'Team Task'**
  String get teamTask;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @closedBy.
  ///
  /// In en, this message translates to:
  /// **'Closed By'**
  String get closedBy;

  /// No description provided for @closedDate.
  ///
  /// In en, this message translates to:
  /// **'Closed Date'**
  String get closedDate;

  /// No description provided for @investigationNotes.
  ///
  /// In en, this message translates to:
  /// **'Investigation Notes'**
  String get investigationNotes;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @correctiveAction.
  ///
  /// In en, this message translates to:
  /// **'Corrective Action'**
  String get correctiveAction;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @trainingRequired.
  ///
  /// In en, this message translates to:
  /// **'Training Required'**
  String get trainingRequired;

  /// No description provided for @performanceEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Performance Evaluation'**
  String get performanceEvaluation;

  /// No description provided for @taskQuality.
  ///
  /// In en, this message translates to:
  /// **'Task Quality'**
  String get taskQuality;

  /// No description provided for @communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @teamwork.
  ///
  /// In en, this message translates to:
  /// **'Teamwork'**
  String get teamwork;

  /// No description provided for @discipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get discipline;

  /// No description provided for @problemSolving.
  ///
  /// In en, this message translates to:
  /// **'Problem Solving'**
  String get problemSolving;

  /// No description provided for @deadlineCommitment.
  ///
  /// In en, this message translates to:
  /// **'Deadline Commitment'**
  String get deadlineCommitment;

  /// No description provided for @overallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Score'**
  String get overallScore;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTasks;

  /// No description provided for @overdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue Tasks'**
  String get overdueTasks;

  /// No description provided for @complaintsCount.
  ///
  /// In en, this message translates to:
  /// **'Complaints Count'**
  String get complaintsCount;

  /// No description provided for @evaluationHistory.
  ///
  /// In en, this message translates to:
  /// **'Evaluation History'**
  String get evaluationHistory;

  /// No description provided for @managerNotes.
  ///
  /// In en, this message translates to:
  /// **'Manager Notes'**
  String get managerNotes;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @module.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get module;

  /// No description provided for @operation.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get operation;

  /// No description provided for @globalSearch.
  ///
  /// In en, this message translates to:
  /// **'Global Search'**
  String get globalSearch;

  /// No description provided for @breadcrumb.
  ///
  /// In en, this message translates to:
  /// **'Breadcrumb'**
  String get breadcrumb;

  /// No description provided for @profileMenu.
  ///
  /// In en, this message translates to:
  /// **'Profile Menu'**
  String get profileMenu;

  /// No description provided for @employeeOverview360.
  ///
  /// In en, this message translates to:
  /// **'360° Employee Overview'**
  String get employeeOverview360;

  /// No description provided for @viewFullDetails.
  ///
  /// In en, this message translates to:
  /// **'View Full Details'**
  String get viewFullDetails;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get uploadFiles;

  /// No description provided for @selectedFiles.
  ///
  /// In en, this message translates to:
  /// **'Selected Files'**
  String get selectedFiles;

  /// No description provided for @sendNotes.
  ///
  /// In en, this message translates to:
  /// **'Send Notes'**
  String get sendNotes;

  /// No description provided for @sendDeliverables.
  ///
  /// In en, this message translates to:
  /// **'Send Deliverables'**
  String get sendDeliverables;

  /// No description provided for @tapToChooseFiles.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose files'**
  String get tapToChooseFiles;

  /// No description provided for @anyFileTypeSupported.
  ///
  /// In en, this message translates to:
  /// **'Any file type is supported (images, PDFs, zip, code...)'**
  String get anyFileTypeSupported;

  /// No description provided for @attachAnyFileTypeToHelpSolveThisTask.
  ///
  /// In en, this message translates to:
  /// **'Attach any file type to help solve this task.'**
  String get attachAnyFileTypeToHelpSolveThisTask;

  /// No description provided for @addNoteOrMessageToHelpSolveThisTask.
  ///
  /// In en, this message translates to:
  /// **'Add a note or message to help solve this task.'**
  String get addNoteOrMessageToHelpSolveThisTask;

  /// No description provided for @writeNoteExplainSolutionOrDescribeWhatYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Write a note, explain your solution, or describe what you need...'**
  String get writeNoteExplainSolutionOrDescribeWhatYouNeed;

  /// No description provided for @pleaseAttachAFileOrWriteANoteFirst.
  ///
  /// In en, this message translates to:
  /// **'Please attach a file or write a note first'**
  String get pleaseAttachAFileOrWriteANoteFirst;

  /// No description provided for @deliverablesSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deliverables sent successfully'**
  String get deliverablesSentSuccessfully;

  /// No description provided for @uploadedFileCount.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {count} file(s)'**
  String uploadedFileCount(Object count);

  /// No description provided for @teamLeaderActions.
  ///
  /// In en, this message translates to:
  /// **'Team Leader Actions'**
  String get teamLeaderActions;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForReview;

  /// No description provided for @reviewDeliverable.
  ///
  /// In en, this message translates to:
  /// **'Review Deliverable'**
  String get reviewDeliverable;

  /// No description provided for @enterReviewFeedback.
  ///
  /// In en, this message translates to:
  /// **'Enter review feedback...'**
  String get enterReviewFeedback;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @approveAndComplete.
  ///
  /// In en, this message translates to:
  /// **'Approve & Complete'**
  String get approveAndComplete;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @reassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// No description provided for @reassignTask.
  ///
  /// In en, this message translates to:
  /// **'Reassign Task'**
  String get reassignTask;

  /// No description provided for @selectTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Select Team Member'**
  String get selectTeamMember;

  /// No description provided for @chooseMember.
  ///
  /// In en, this message translates to:
  /// **'Choose member...'**
  String get chooseMember;

  /// No description provided for @taskMarkedAs.
  ///
  /// In en, this message translates to:
  /// **'Task marked as {status}'**
  String taskMarkedAs(Object status);

  /// No description provided for @taskReassignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task reassigned successfully'**
  String get taskReassignedSuccessfully;

  /// No description provided for @taskUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdatedSuccessfully;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @myComplaints.
  ///
  /// In en, this message translates to:
  /// **'My Complaints'**
  String get myComplaints;

  /// No description provided for @trackAndManageYourSubmittedComplaints.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your submitted complaints'**
  String get trackAndManageYourSubmittedComplaints;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @complaintAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Complaint Analytics'**
  String get complaintAnalytics;

  /// No description provided for @complaintPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Your complaint is pending review.'**
  String get complaintPendingReview;

  /// No description provided for @complaintClosed.
  ///
  /// In en, this message translates to:
  /// **'This complaint has been closed.'**
  String get complaintClosed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
