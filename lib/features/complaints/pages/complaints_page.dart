import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/network/mock_database.dart';
import '../../../responsive/responsive_layout.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/cubit/auth_cubit.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _resolutionController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final role = user.role;

    final complaints = MockDatabase.instance.complaints.where((c) {
      final matchesSearch =
          c.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          c.description.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      // Let members only see their own complaints, while Admins/Managers/Leaders see all related complaints
      if (role == 'Team Member') {
        return matchesSearch && c.submitterId == user.id;
      }
      return matchesSearch;
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
                        'Complaints & Investigations',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Submit and track issues, workload, or deadline complaints',
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
                    label: const Text(
                      'File Complaint',
                      style: TextStyle(
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
                    hintText: 'Search complaints by title...',
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
                    ? const Center(child: Text('No complaints registered.'))
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
                                    'Submitted by: ${c.submitterName} (${c.submitterRole}) on ${c.date}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    'Target: ${c.targetType} - ${c.targetName}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  const Divider(),
                                  Text(
                                    c.description,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[800],
                                      height: 1.4,
                                    ),
                                  ),
                                  if (c.resolutionNotes.isNotEmpty) ...[
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.green[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        'Resolution Notes: ${c.resolutionNotes}',
                                        style: TextStyle(
                                          color: Colors.green[800],
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (role != 'Team Member' &&
                                      c.status != 'Resolved' &&
                                      c.status != 'Closed') ...[
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () =>
                                              _handleUpdateComplaint(
                                                context,
                                                c.id,
                                                'Under Investigation',
                                              ),
                                          child: const Text('Investigate'),
                                        ),
                                        SizedBox(width: 12.w),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _handleUpdateComplaint(
                                                context,
                                                c.id,
                                                'Resolved',
                                              ),
                                          child: const Text(
                                            'Mark Resolved',
                                            style: TextStyle(
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
        status,
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
          title: const Text(
            'Submit a Complaint',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Complaint Title',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    initialValue: targetType,
                    decoration: const InputDecoration(
                      labelText: 'Complaint Target',
                    ),
                    items:
                        [
                              'Member',
                              'Team Leader',
                              'Manager',
                              'Team',
                              'Workload Issue',
                              'Deadline Issue',
                            ]
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
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
                    decoration: const InputDecoration(
                      labelText: 'Target Identifier / Name',
                      hintText: 'e.g. Sarah Ahmed, Budget Task',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Complaint Details / Context',
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                  setState(() {
                    MockDatabase.instance.addComplaint(
                      MockComplaint(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        submitterId: user.id,
                        submitterName: user.fullName ?? 'Member',
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
                    const SnackBar(
                      content: Text(
                        'Complaint submitted and escalated successfully.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
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
          'Update Complaint Status to: $status',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _resolutionController,
          decoration: const InputDecoration(
            labelText: 'Notes / Comments',
            hintText: 'Enter resolution notes or status details...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                SnackBar(content: Text('Complaint status updated to: $status')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
