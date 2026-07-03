import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../auth/cubit/auth_cubit.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedRange = 'Month'; // 'Day' | 'Week' | 'Month' | 'Year' | 'Custom'
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final db = MockDatabase.instance;

    // Calculate metrics dynamically
    final totalTasks = db.tasks.length;
    final completedTasks = db.tasks.where((t) => t.status == 'Approved' || t.status == 'Completed').length;
    final delayedTasks = db.tasks.where((t) => t.status != 'Approved' && t.status != 'Completed' && DateTime.tryParse(t.deadline)?.isBefore(DateTime.now()) == true).length;
    
    final double approvalRate = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;
    final rejectedTasks = db.tasks.where((t) => t.status == 'Rejected').length;
    final double rejectionRate = totalTasks == 0 ? 0.0 : (rejectedTasks / totalTasks) * 100;

    // Best/Worst members
    final members = db.users.where((u) => u.role == 'Team Member').toList();
    final sortedMembers = List<MockUser>.from(members)..sort((a, b) => b.points.compareTo(a.points));
    final bestMember = sortedMembers.isNotEmpty ? sortedMembers.first.fullName : 'N/A';
    final worstMember = sortedMembers.length > 1 ? sortedMembers.last.fullName : 'N/A';

    // Best/Worst Leaders
    final leaders = db.users.where((u) => u.role == 'Team Leader').toList();
    final bestLeader = leaders.isNotEmpty ? leaders.first.fullName : 'N/A';
    final worstLeader = leaders.length > 1 ? leaders.last.fullName : 'N/A';

    // Best/Worst managers
    final managers = db.users.where((u) => u.role == 'Manager').toList();
    final bestManager = managers.isNotEmpty ? managers.first.fullName : 'N/A';
    final worstManager = managers.length > 1 ? managers.last.fullName : 'N/A';

    // Best/Worst Team
    final sortedTeams = List<MockTeam>.from(db.teams)..sort((a, b) => b.progress.compareTo(a.progress));
    final bestTeam = sortedTeams.isNotEmpty ? sortedTeams.first.name : 'N/A';
    final worstTeam = sortedTeams.length > 1 ? sortedTeams.last.name : 'N/A';

    final totalComplaints = db.complaints.length;
    final resolvedComplaints = db.complaints.where((c) => c.status == 'Resolved' || c.status == 'Closed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Performance Reports',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Review analytical reports and output metrics',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                      ),
                    ],
                  ),
                  // Export Actions
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showExportModal(context, 'PDF', _generateReportContent(db)),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        label: const Text('Export PDF'),
                      ),
                      SizedBox(width: 8.w),
                      OutlinedButton.icon(
                        onPressed: () => _showExportModal(context, 'Excel', _generateReportContent(db)),
                        icon: const Icon(Icons.table_view, color: Colors.green),
                        label: const Text('Export Excel'),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        onPressed: () => _showExportModal(context, 'Print', _generateReportContent(db)),
                        icon: const Icon(Icons.print, color: Colors.white),
                        label: const Text('Print Report', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Filter Tabs
              Row(
                children: ['Day', 'Week', 'Month', 'Year', 'Custom Range'].map((range) {
                  final isSelected = _selectedRange == range;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(range),
                      selected: isSelected,
                      onSelected: (val) async {
                        if (range == 'Custom Range') {
                          final selected = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2027),
                          );
                          if (selected != null) {
                            setState(() {
                              _customDateRange = selected;
                              _selectedRange = range;
                            });
                          }
                        } else {
                          setState(() {
                            _selectedRange = range;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              if (_selectedRange == 'Custom Range' && _customDateRange != null) ...[
                SizedBox(height: 12.h),
                Text(
                  'Filtering from: ${DateFormat('yyyy-MM-dd').format(_customDateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(_customDateRange!.end)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
              SizedBox(height: 24.h),

              // Statistics Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.5,
                children: [
                  _buildStatTile('Best Team', bestTeam, Colors.blue),
                  _buildStatTile('Best Leader', bestLeader, Colors.purple),
                  _buildStatTile('Best Member', bestMember, Colors.green),
                  _buildStatTile('Best Manager', bestManager, Colors.orange),
                  _buildStatTile('Worst Team', worstTeam, Colors.redAccent),
                  _buildStatTile('Worst Leader', worstLeader, Colors.redAccent),
                  _buildStatTile('Worst Member', worstMember, Colors.redAccent),
                  _buildStatTile('Worst Manager', worstManager, Colors.redAccent),
                ],
              ),
              SizedBox(height: 24.h),

              // Analysis Charts
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('University Task Statistics', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            const Divider(height: 24),
                            _buildReportProgressBar('Tasks Approved / Completed', completedTasks, totalTasks, Colors.green),
                            SizedBox(height: 16.h),
                            _buildReportProgressBar('Delayed Tasks', delayedTasks, totalTasks, Colors.red),
                            SizedBox(height: 16.h),
                            _buildReportProgressBar('Rejected Submissions', rejectedTasks, totalTasks, Colors.orange),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Complaint Stats', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            const Divider(height: 24),
                            SizedBox(
                              width: 100.w,
                              height: 100.h,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: totalComplaints == 0 ? 0.0 : (resolvedComplaints / totalComplaints),
                                    strokeWidth: 8.w,
                                    backgroundColor: Colors.grey[200],
                                    color: Colors.redAccent,
                                  ),
                                  Center(
                                    child: Text(
                                      '$resolvedComplaints/$totalComplaints\nResolved',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(left: BorderSide(color: color, width: 4.w)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReportProgressBar(String title, int count, int total, Color color) {
    final double pct = total == 0 ? 0.0 : (count / total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$count of $total (${(pct * 100).toInt()}%)'),
          ],
        ),
        SizedBox(height: 6.h),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 8.h,
        ),
      ],
    );
  }

  String _generateReportContent(db) {
    final reportDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return '''
==========================================
UNIVERSITY TASK & TEAM PERFORMANCE REPORT
Report Date: $reportDate
Range Filter: $_selectedRange
==========================================

[PROJECT HEALTH]
Global Health Index: 85% (Operational)

[TASK SUMMARY]
Total Tasks: ${db.tasks.length}
Completed/Approved: ${db.tasks.where((t) => t.status == 'Approved' || t.status == 'Completed').length}
Delayed: ${db.tasks.where((t) => t.status != 'Approved' && t.status != 'Completed' && DateTime.tryParse(t.deadline)?.isBefore(DateTime.now()) == true).length}

[RANKS]
Best Performing Team: Software Engineering Team
Best Performing Member: Sarah Ahmed
Best Performing Leader: Eng. Nour Hassan

[COMPLAINTS]
Total Logged: ${db.complaints.length}
Resolved complaints: ${db.complaints.where((c) => c.status == 'Resolved').length}
==========================================
    ''';
  }

  void _showExportModal(BuildContext context, String mode, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Exporting Report as $mode', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8.r)),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully downloaded/printed report as $mode')),
              );
            },
            child: Text('Download $mode'),
          ),
        ],
      ),
    );
  }
}

class ReportModel {
  final String id;
  final String title;
  final String content;
  final String taskName;
  final String department;
  final String teamName;
  final String submitter;
  final String date;
  final List<String> attachments;

  ReportModel({
    required this.id,
    required this.title,
    required this.content,
    required this.taskName,
    required this.department,
    required this.teamName,
    required this.submitter,
    required this.date,
    this.attachments = const [],
  });
}

class ReportsDatabase {
  static final List<ReportModel> reports = [
    ReportModel(
      id: '1',
      title: 'Q2 System Vulnerability Scan Report',
      content: 'Completed the security audit scan across all primary subnets. Patched three high-risk vulnerabilities on the enrollment server. System latency remains within standard deviation limits, and port scans show no anomalous behavior.',
      taskName: 'Security Vulnerability Assessment',
      department: 'IT Services',
      teamName: 'IT Infrastructure Team',
      submitter: 'Dr. Karim Tarek',
      date: 'Jun 22, 2026',
      attachments: const ['vulnerability_scan_results.pdf', 'enrollment_server_logs.txt'],
    ),
    ReportModel(
      id: '2',
      title: 'LMS API Performance Optimization Report',
      content: 'Optimized third-party database calls in the student portal, reducing API load time by 34%. All integrations tested successfully under simulated concurrent loads of up to 5,000 active sessions.',
      taskName: 'API Integration Review',
      department: 'CS Dept',
      teamName: 'Software Engineering Team',
      submitter: 'Dr. Sarah Ahmed',
      date: 'Jun 18, 2026',
      attachments: const ['api_perf_metrics.xlsx'],
    ),
    ReportModel(
      id: '3',
      title: 'Department Budget Alignment Review',
      content: 'Analyzed departmental expense reports for Q1. Alignments are within the projected margin of error, but recommendations for software license consolidation have been detailed in the attachments.',
      taskName: 'Annual Budget Report',
      department: 'Business',
      teamName: 'Finance Management',
      submitter: 'Dr. Samira Hegazi',
      date: 'Jun 15, 2026',
      attachments: const ['consolidated_licenses.pdf', 'q1_budget_allocation.csv'],
    ),
  ];
}
