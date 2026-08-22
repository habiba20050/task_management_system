import 'dart:io';
import 'dart:convert';

void main() async {
  final extFile = File('lib/core/localization/translate_extension.dart');
  final arArbFile = File('lib/l10n/app_ar.arb');
  
  if (!extFile.existsSync() || !arArbFile.existsSync()) {
    print('Files not found');
    return;
  }
  
  final extContent = extFile.readAsStringSync();
  final arArbContent = arArbFile.readAsStringSync();
  
  final Map<String, dynamic> arArb = jsonDecode(arArbContent);
  
  final Map<String, String> enJson = {};
  final Map<String, String> arJson = {};
  
  final RegExp caseRegex = RegExp(r"case\s+'([^']+)':\s+return localizations\.([a-zA-Z0-9_]+);");
  final matches = caseRegex.allMatches(extContent);
  
  for (final match in matches) {
    final uiString = match.group(1)!;
    final arbKey = match.group(2)!;
    
    enJson[uiString] = uiString;
    
    if (arArb.containsKey(arbKey)) {
      arJson[uiString] = arArb[arbKey];
    } else {
      arJson[uiString] = uiString; // fallback
    }
  }
  
  final RegExp ternaryRegex = RegExp(r"case\s+'([^']+)':\s+return localizations\.localeName == 'ar' \? '([^']+)' : '([^']+)';");
  final ternaryMatches = ternaryRegex.allMatches(extContent);
  for (final match in ternaryMatches) {
    final uiString = match.group(1)!;
    final arString = match.group(2)!;
    final enString = match.group(3)!;
    
    enJson[uiString] = enString;
    arJson[uiString] = arString;
  }
  
  File('assets/lang/en.json').writeAsStringSync(jsonEncode(enJson));
  File('assets/lang/ar.json').writeAsStringSync(jsonEncode(arJson));
  
  print('Done converting ${enJson.length} keys.');
}
