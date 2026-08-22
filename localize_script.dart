import 'dart:io';
import 'dart:convert';

void main() async {
  final filesToFix = [
    'lib/user/admin/features/profile/pages/profile_page.dart',
    'lib/user/manager/features/profile/pages/profile_page.dart',
    'lib/user/team_leader/features/profile/pages/profile_page.dart',
    'lib/user/team_member/features/profile/pages/profile_page.dart',
  ];

  Set<String> newKeys = {};

  final textRegex = RegExp(r"Text\(\s*'([^']+)'\s*[,)]");
  final hintRegex = RegExp(r"hintText:\s*'([^']+)'");
  final labelRegex = RegExp(r"label:\s*'([^']+)'");
  final contentRegex = RegExp(r"content:\s*Text\(\s*'([^']+)'\s*\)");

  for (String path in filesToFix) {
    File file = File(path);
    if (!await file.exists()) continue;

    String content = await file.readAsString();
    bool modified = false;

    // Helper to replace and collect keys
    String replaceWithTr(Match match, String fullMatch, String textKey) {
      if (textKey.isEmpty || textKey == ' ') return fullMatch;
      // Skip if already translated (e.g. Text('...'.tr())) -- handled by regex not matching it if it has .tr()
      // Wait, the regex matches `Text('Hello')`, if it was `Text('Hello'.tr())` it wouldn't match `Text('...')` exactly because of the `.tr()`.
      // Actually, if it has `.tr()`, it looks like `Text('Hello'.tr())`.
      // My regex `Text('([^']+)'[,)]` would NOT match `Text('Hello'.tr())` because of the `.tr`. Wait, the `)` might match. Let's make sure it doesn't match `.tr()`.
      
      newKeys.add(textKey);
      return fullMatch.replaceFirst("'$textKey'", "'$textKey'.tr()");
    }

    // Pass 1: Text('...')
    content = content.replaceAllMapped(RegExp(r"Text\(\s*'([^']+)'\s*(?=[,\)])"), (match) {
      return replaceWithTr(match, match.group(0)!, match.group(1)!);
    });

    // Pass 2: hintText: '...'
    content = content.replaceAllMapped(RegExp(r"hintText:\s*'([^']+)'(?!\.tr\(\))"), (match) {
      return replaceWithTr(match, match.group(0)!, match.group(1)!);
    });
    
    // Pass 3: label: '...'
    content = content.replaceAllMapped(RegExp(r"label:\s*'([^']+)'(?!\.tr\(\))"), (match) {
      return replaceWithTr(match, match.group(0)!, match.group(1)!);
    });

    await file.writeAsString(content);
    print('Processed $path');
  }

  // Load ar.json
  File arFile = File('assets/lang/ar.json');
  File enFile = File('assets/lang/en.json');
  
  Map<String, dynamic> arJson = jsonDecode(await arFile.readAsString());
  Map<String, dynamic> enJson = jsonDecode(await enFile.readAsString());

  int added = 0;
  for (String key in newKeys) {
    if (!arJson.containsKey(key)) {
      arJson[key] = "TODO_ARABIC: $key";
      enJson[key] = key;
      added++;
    }
  }

  if (added > 0) {
    await arFile.writeAsString(jsonEncode(arJson));
    await enFile.writeAsString(jsonEncode(enJson));
    print('Added $added missing keys to language files.');
  } else {
    print('No missing keys found.');
  }
}
