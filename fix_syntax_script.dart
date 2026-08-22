import 'dart:io';

void main() async {
  final filesToFix = [
    'lib/user/admin/features/profile/pages/profile_page.dart',
    'lib/user/manager/features/profile/pages/profile_page.dart',
    'lib/user/team_leader/features/profile/pages/profile_page.dart',
    'lib/user/team_member/features/profile/pages/profile_page.dart',
  ];

  for (String path in filesToFix) {
    File file = File(path);
    if (!await file.exists()) continue;

    String content = await file.readAsString();

    content = content.replaceFirst(
      "SnackBar(content: Text('Password updated successfully!'.tr(context)), backgroundColor: AppColors.success),\n                  backgroundColor: AppColors.success,\n                ),",
      "SnackBar(\n                  content: Text('Password updated successfully!'.tr(context)),\n                  backgroundColor: AppColors.success,\n                ),"
    );

    content = content.replaceFirst(
      "SnackBar(content: Text('Personal information updated successfully!'.tr(context)), backgroundColor: AppColors.success),\n                  backgroundColor: AppColors.success,\n                ),",
      "SnackBar(\n                  content: Text('Personal information updated successfully!'.tr(context)),\n                  backgroundColor: AppColors.success,\n                ),"
    );

    content = content.replaceFirst(
      "ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all password fields.'.tr(context)))));",
      "ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all password fields.'.tr(context))));"
    );

    content = content.replaceFirst(
      "ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match.'.tr(context)))));",
      "ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match.'.tr(context))));"
    );

    await file.writeAsString(content);
    print('Fixed syntax in $path');
  }
}
