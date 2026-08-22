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

    // Fix 1: Text($1)
    content = content.replaceAll(
      'Text(\$1),',
      "Text('Retry'.tr(context)),"
    );

    // Fix 2: SnackBar($1) for Password update
    content = content.replaceFirst(
      'SnackBar(\$1),',
      "SnackBar(content: Text('Password updated successfully!'.tr(context)), backgroundColor: AppColors.success),"
    );

    // Fix 3: SnackBar($1) for Personal Info update
    content = content.replaceFirst(
      'SnackBar(\$1),',
      "SnackBar(content: Text('Personal information updated successfully!'.tr(context)), backgroundColor: AppColors.success),"
    );

    // Fix 4 & 5: SnackBar($1) for validation errors
    content = content.replaceFirst(
      'SnackBar(\$1)',
      "SnackBar(content: Text('Please fill all password fields.'.tr(context)))"
    );

    content = content.replaceFirst(
      'SnackBar(\$1)',
      "SnackBar(content: Text('Passwords do not match.'.tr(context)))"
    );

    await file.writeAsString(content);
    print('Restored $path');
  }
}
