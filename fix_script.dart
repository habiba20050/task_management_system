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
    
    // Replace .tr() with .tr(context)
    content = content.replaceAll('.tr()', '.tr(context)');
    
    // Remove const from Text('...'.tr(context))
    content = content.replaceAll(RegExp(r"const\s+Text\(([^)]+\.tr\(context\)[^)]*)\)"), r"Text($1)");
    
    // Remove const from SnackBar if it contains .tr(context)
    content = content.replaceAll(RegExp(r"const\s+SnackBar\(([^)]+\.tr\(context\)[^)]*)\)"), r"SnackBar($1)");
    
    // It's possible SnackBar is multi-line, but in the error it looks like one line:
    // const SnackBar(content: Text('Passwords do not match.'.tr(context)))
    // If the regex misses it, let's just do a naive replace for those specific strings:
    content = content.replaceAll("const SnackBar(content: Text('Please fill all password fields.'.tr(context)))", "SnackBar(content: Text('Please fill all password fields.'.tr(context)))");
    content = content.replaceAll("const SnackBar(content: Text('Passwords do not match.'.tr(context)))", "SnackBar(content: Text('Passwords do not match.'.tr(context)))");

    // Fix other const issues
    content = content.replaceAll("const Text('Retry'.tr(context))", "Text('Retry'.tr(context))");

    await file.writeAsString(content);
    print('Fixed $path');
  }
}
