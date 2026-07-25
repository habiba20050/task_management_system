import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../colors/app_colors.dart';
import '../../styles/app_radius.dart';

class AppDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? headingRowHeight;
  final double? dataRowHeight;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.headingRowHeight,
    this.dataRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: headingRowHeight ?? 48.h,
          dataRowHeight: dataRowHeight ?? 56.h,
          headingRowColor: MaterialStateProperty.all(AppColors.background),
          dividerThickness: 1,
          horizontalMargin: 16.w,
          columnSpacing: 24.w,
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}
