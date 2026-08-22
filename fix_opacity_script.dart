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

    // Replace .withOpacity(x) with .withValues(alpha: x)
    content = content.replaceAllMapped(
      RegExp(r'\.withOpacity\(([^)]+)\)'),
      (match) => '.withValues(alpha: ${match.group(1)})',
    );

    await file.writeAsString(content);
    print('Fixed opacity in $path');
  }
}
