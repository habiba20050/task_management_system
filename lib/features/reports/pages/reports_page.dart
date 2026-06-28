import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/colors/app_colors.dart';
import '../../../responsive/responsive_layout.dart';

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

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDeptFilter = 'All';

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp),
      fillColor: const Color(0xFFEDF2F7),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateReportDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final taskController = TextEditingController();
    String selectedDept = 'CS Dept';
    String selectedTeam = 'Software Engineering Team';
    List<String> tempAttachments = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Create New Report',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          content: SizedBox(
            width: 500.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFieldLabel('Report Title'),
                  TextField(
                    controller: titleController,
                    decoration: _buildInputDecoration('Enter report title...'),
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Related Task Name'),
                  TextField(
                    controller: taskController,
                    decoration: _buildInputDecoration('e.g. Budget Audit'),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Department'),
                            DropdownButtonFormField<String>(
                              initialValue: selectedDept,
                              decoration: _buildInputDecoration(''),
                              items: const [
                                DropdownMenuItem(value: 'CS Dept', child: Text('CS Dept')),
                                DropdownMenuItem(value: 'IT Services', child: Text('IT Services')),
                                DropdownMenuItem(value: 'Business', child: Text('Business')),
                                DropdownMenuItem(value: 'Engineering Dept', child: Text('Engineering')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedDept = val;
                                    if (val == 'CS Dept') selectedTeam = 'Software Engineering Team';
                                    else if (val == 'IT Services') selectedTeam = 'IT Infrastructure Team';
                                    else if (val == 'Business') selectedTeam = 'Finance Management';
                                    else selectedTeam = 'General Team';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Team'),
                            DropdownButtonFormField<String>(
                              value: selectedTeam,
                              decoration: _buildInputDecoration(''),
                              items: [selectedTeam].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Report Description / Findings'),
                  TextField(
                    controller: contentController,
                    decoration: _buildInputDecoration('Enter report findings...'),
                    maxLines: 4,
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldLabel('Attachments'),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            final mockFiles = ['metrics_summary.xlsx', 'audit_log.txt', 'consolidated_report.pdf', 'system_spec.docx'];
                            final nextFile = mockFiles[tempAttachments.length % mockFiles.length];
                            tempAttachments.add('${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}_$nextFile');
                          });
                        },
                        icon: Icon(Icons.attach_file, size: 14.sp, color: const Color(0xFF0F4C81)),
                        label: Text('Attach File', style: TextStyle(color: const Color(0xFF0F4C81), fontSize: 12.sp)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                    ],
                  ),
                  if (tempAttachments.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: tempAttachments.map((file) => Chip(
                        backgroundColor: const Color(0xFFEDF2F7),
                        label: Text(file, style: TextStyle(fontSize: 10.sp, color: Colors.grey[700])),
                        deleteIcon: Icon(Icons.close, size: 12.sp, color: Colors.red[400]),
                        onDeleted: () {
                          setDialogState(() {
                            tempAttachments.remove(file);
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r), side: BorderSide.none),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  setState(() {
                    ReportsDatabase.reports.add(
                      ReportModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        content: contentController.text,
                        taskName: taskController.text.isNotEmpty ? taskController.text : 'General Review',
                        department: selectedDept,
                        teamName: selectedTeam,
                        submitter: 'Dr. Ahmed',
                        date: DateFormat('MMM d, yyyy').format(DateTime.now()),
                        attachments: tempAttachments,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReportDialog(ReportModel report) {
    final titleController = TextEditingController(text: report.title);
    final contentController = TextEditingController(text: report.content);
    final taskController = TextEditingController(text: report.taskName);
    String selectedDept = report.department;
    String selectedTeam = report.teamName;
    List<String> tempAttachments = List.from(report.attachments);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Edit Report',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          content: SizedBox(
            width: 500.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFieldLabel('Report Title'),
                  TextField(
                    controller: titleController,
                    decoration: _buildInputDecoration('Enter report title...'),
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Related Task Name'),
                  TextField(
                    controller: taskController,
                    decoration: _buildInputDecoration('e.g. Budget Audit'),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Department'),
                            DropdownButtonFormField<String>(
                              value: selectedDept,
                              decoration: _buildInputDecoration(''),
                              items: const [
                                DropdownMenuItem(value: 'CS Dept', child: Text('CS Dept')),
                                DropdownMenuItem(value: 'IT Services', child: Text('IT Services')),
                                DropdownMenuItem(value: 'Business', child: Text('Business')),
                                DropdownMenuItem(value: 'Engineering Dept', child: Text('Engineering')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedDept = val;
                                    if (val == 'CS Dept') selectedTeam = 'Software Engineering Team';
                                    else if (val == 'IT Services') selectedTeam = 'IT Infrastructure Team';
                                    else if (val == 'Business') selectedTeam = 'Finance Management';
                                    else selectedTeam = 'General Team';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Team'),
                            DropdownButtonFormField<String>(
                              value: selectedTeam,
                              decoration: _buildInputDecoration(''),
                              items: [selectedTeam].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildFieldLabel('Report Description / Findings'),
                  TextField(
                    controller: contentController,
                    decoration: _buildInputDecoration('Enter report findings...'),
                    maxLines: 4,
                  ),
                  SizedBox(height: 16.h),
                  _buildFieldLabel('Attachments'),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            final mockFiles = ['metrics_summary.xlsx', 'audit_log.txt', 'consolidated_report.pdf', 'system_spec.docx'];
                            final nextFile = mockFiles[tempAttachments.length % mockFiles.length];
                            tempAttachments.add('${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}_$nextFile');
                          });
                        },
                        icon: Icon(Icons.attach_file, size: 14.sp, color: const Color(0xFF0F4C81)),
                        label: Text('Attach File', style: TextStyle(color: const Color(0xFF0F4C81), fontSize: 12.sp)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                    ],
                  ),
                  if (tempAttachments.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: tempAttachments.map((file) => Chip(
                        backgroundColor: const Color(0xFFEDF2F7),
                        label: Text(file, style: TextStyle(fontSize: 10.sp, color: Colors.grey[700])),
                        deleteIcon: Icon(Icons.close, size: 12.sp, color: Colors.red[400]),
                        onDeleted: () {
                          setDialogState(() {
                            tempAttachments.remove(file);
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r), side: BorderSide.none),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  setState(() {
                    final idx = ReportsDatabase.reports.indexWhere((r) => r.id == report.id);
                    if (idx != -1) {
                      ReportsDatabase.reports[idx] = ReportModel(
                        id: report.id,
                        title: titleController.text,
                        content: contentController.text,
                        taskName: taskController.text.isNotEmpty ? taskController.text : 'General Review',
                        department: selectedDept,
                        teamName: selectedTeam,
                        submitter: report.submitter,
                        date: report.date,
                        attachments: tempAttachments,
                      );
                    }
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetailDialog(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                report.title,
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        content: SizedBox(
          width: 600.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTag(report.department, const Color(0xFFEFF6FF), const Color(0xFF1E3A8A)),
                  SizedBox(width: 8.w),
                  _buildTag(report.teamName, const Color(0xFFF3E8FF), const Color(0xFF5B21B6)),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Submitted by: ${report.submitter} on ${report.date}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              Text(
                'Related Task: ${report.taskName}',
                style: TextStyle(color: const Color(0xFF0F4C81), fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              Text(
                report.content,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, height: 1.5),
              ),
              if (report.attachments.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  'Attachments',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: report.attachments.map((file) => InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading file: $file')),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.insert_drive_file_outlined, size: 14.sp, color: const Color(0xFF0F4C81)),
                          SizedBox(width: 6.w),
                          Text(
                            file,
                            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF334155), decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditReportDialog(report);
            },
            icon: const Icon(Icons.edit, color: Colors.white, size: 16),
            label: const Text('Edit Report', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C81),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Mark as Reviewed', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6.r)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // Filter reports
    final filteredReports = ReportsDatabase.reports.where((report) {
      final matchesSearch = report.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          report.taskName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          report.submitter.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesDept = _selectedDeptFilter == 'All' || report.department == _selectedDeptFilter;
      return matchesSearch && matchesDept;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Documentation',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Department tasks audit, findings and documentation',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateReportDialog(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Create New Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C81),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 2. Stats summary cards
              Row(
                children: [
                  _buildStatCard('Total Reports', ReportsDatabase.reports.length.toString(), Icons.description_outlined, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
                  SizedBox(width: 16.w),
                  _buildStatCard('Awaiting Review', '1', Icons.pending_actions_outlined, const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
                  SizedBox(width: 16.w),
                  _buildStatCard('Reviewed', (ReportsDatabase.reports.length - 1).toString(), Icons.verified_user_outlined, const Color(0xFF10B981), const Color(0xFFE6F4EA)),
                ],
              ),
              SizedBox(height: 32.h),

              // 3. Search and Filter Row
              Row(
                children: [
                  SizedBox(
                    width: 350.w,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search reports by title, task, or submitter...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                          prefixIcon: Icon(Icons.search, size: 18.sp, color: const Color(0xFF0F4C81)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDeptFilter,
                        items: ['All', 'CS Dept', 'IT Services', 'Business', 'Engineering Dept']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d, style: TextStyle(fontSize: 13.sp))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDeptFilter = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 4. Reports List/Table
              Expanded(
                child: filteredReports.isEmpty
                    ? const Center(
                        child: Text(
                          'No reports found matching your criteria.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : 1,
                          crossAxisSpacing: 24.w,
                          mainAxisSpacing: 24.h,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = filteredReports[index];
                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTag(report.department, const Color(0xFFEFF6FF), const Color(0xFF1E3A8A)),
                                      Row(
                                        children: [
                                          Text(report.date, style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                                          SizedBox(width: 4.w),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert, size: 16.sp, color: Colors.grey[500]),
                                            padding: EdgeInsets.zero,
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                _showEditReportDialog(report);
                                              } else if (val == 'delete') {
                                                setState(() {
                                                  ReportsDatabase.reports.removeWhere((r) => r.id == report.id);
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Report deleted successfully')),
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 14.sp, color: const Color(0xFF0F4C81)),
                                                    SizedBox(width: 6.w),
                                                    Text('Edit', style: TextStyle(fontSize: 12.sp)),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, size: 14.sp, color: Colors.red[700]),
                                                    SizedBox(width: 6.w),
                                                    Text('Delete', style: TextStyle(fontSize: 12.sp, color: Colors.red[700])),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    report.title,
                                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    report.content,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp, height: 1.3),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('By: ${report.submitter}', style: TextStyle(color: Colors.grey[700], fontSize: 11.sp, fontWeight: FontWeight.w600)),
                                      TextButton(
                                        onPressed: () => _showReportDetailDialog(report),
                                        child: Row(
                                          children: [
                                            Text('View Full', style: TextStyle(color: const Color(0xFF0F4C81), fontSize: 11.sp, fontWeight: FontWeight.bold)),
                                            Icon(Icons.keyboard_arrow_right, size: 14.sp, color: const Color(0xFF0F4C81)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, Color iconBgColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
