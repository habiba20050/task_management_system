import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../language/cubit/language_cubit.dart';
import '../../../core/localization/translate_extension.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _resolutionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;
    final dynamic user = authState is AuthSuccess
        ? authState.user
        : MockUser(id: '', email: '', fullName: 'Member'.tr(context), role: 'Team Member', department: '');

    final db = MockDatabase.instance;

    final complaints = db.complaints.where((c) {
      // 1. Role-based visibility
      if (user.role == 'Team Member' && c.submitterId != user.id) {
        return false;
      }
      if (user.role == 'Team Leader' && c.submitterId != user.id) {
        // Leaders can see their own complaints, or team members' complaints if they target their team
        // For simplicity of the mockup, show leader's own complaints or open team issues
        if (c.submitterId != user.id && c.targetType != 'Team') {
          return false;
        }
      }

      // 2. Search filter
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        return c.title.toLowerCase().contains(query) ||
            c.description.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complaints & Investigations'.tr(context),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Submit and track issues, workload, or deadline complaints'.tr(context),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showSubmitComplaintDialog(context, user),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'File Complaint'.tr(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Search Bar
              Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search complaints by title...'.tr(context),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
              SizedBox(height: 24.h),

              Expanded(
                child: complaints.isEmpty
                    ? Center(child: Text('No complaints registered.'.tr(context)))
                    : ListView.separated(
                        itemCount: complaints.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final c = complaints[index];
                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        c.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      _buildStatusChip(c.status),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Submitted by'.tr(context) + ': ${c.submitterName} (${c.submitterRole}) on ${c.date}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    c.description,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 14.sp,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Target Name'.tr(context) + ': ${c.targetName} (${c.targetType.tr(context)})',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (c.resolutionNotes != null &&
                                      c.resolutionNotes!.isNotEmpty) ...[
                                    const Divider(),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Resolution Notes'.tr(context) + ':',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      c.resolutionNotes!,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[800],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                  if (user.role == 'Admin' ||
                                      user.role == 'Manager') ...[
                                    const Divider(),
                                    SizedBox(height: 8.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _handleUpdateComplaint(
                                            context,
                                            c.id,
                                            'Under Investigation',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber[700],
                                          ),
                                          child: Text(
                                            'Mark Investigating'.tr(context),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _handleUpdateComplaint(
                                            context,
                                            c.id,
                                            'Resolved',
                                          ),
                                          child: Text(
                                            'Mark Resolved'.tr(context),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Open') {
      color = Colors.red;
    } else if (status == 'Under Investigation') {
      color = Colors.amber;
    } else if (status == 'Resolved') {
      color = Colors.green;
    }
    return Chip(
      label: Text(
        status.tr(context),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  void _showSubmitComplaintDialog(BuildContext context, user) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String targetType = 'Member';
    final targetNameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Submit a Complaint'.tr(context),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Complaint Title'.tr(context),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    initialValue: targetType,
                    decoration: InputDecoration(
                      labelText: 'Complaint Target'.tr(context),
                    ),
                    items: [
                      'Member',
                      'Team Leader',
                      'Manager',
                      'Team',
                      'Workload Issue',
                      'Deadline Issue',
                    ]
                        .map(
                          (t) => DropdownMenuItem(value: t, child: Text(t.tr(context))),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => targetType = val);
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: targetNameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Target Identifier / Name'.tr(context),
                      hintText: 'e.g. Sarah Ahmed, Budget Task'.tr(context),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: 'Complaint Details / Context'.tr(context),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'.tr(context)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                  setState(() {
                    MockDatabase.instance.addComplaint(
                      MockComplaint(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        submitterId: user.id,
                        submitterName: user.fullName ?? 'Member'.tr(context),
                        submitterRole: user.role,
                        targetType: targetType,
                        targetId: 't1',
                        targetName: targetNameCtrl.text,
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        date: '2026-07-03',
                        status: 'Open',
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Complaint submitted and escalated successfully.'.tr(context),
                      ),
                    ),
                  );
                }
              },
              child: Text('Submit'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpdateComplaint(
    BuildContext context,
    String complaintId,
    String status,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Update Complaint Status to:'.tr(context) + ' ' + status.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _resolutionController,
          decoration: InputDecoration(
            labelText: 'Notes / Comments'.tr(context),
            hintText: 'Enter resolution notes or status details...'.tr(context),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                MockDatabase.instance.updateComplaintStatus(
                  complaintId,
                  status,
                  _resolutionController.text,
                );
              });
              _resolutionController.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Complaint status updated successfully.'.tr(context))),
              );
            },
            child: Text('Update'.tr(context)),
          ),
        ],
      ),
    );
  }
}
