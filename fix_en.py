# -*- coding: utf-8 -*-
import os
import re
import json

# Scan all dart files for .tr() calls
dart_files = []
for root, _, files in os.walk('w:/task_management_system/lib'):
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

pattern = re.compile(r"'([^']+)'\.tr\([^)]*\)")
keys_in_code = set()
for file_path in dart_files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        matches = pattern.findall(content)
        for key in matches:
            keys_in_code.add(key)

en_path = 'w:/task_management_system/assets/lang/en.json'
ar_path = 'w:/task_management_system/assets/lang/ar.json'

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)
with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

# Add missing from code to en.json
added = 0
for k in keys_in_code:
    if k not in en_data:
        en_data[k] = k
        added += 1
    if k not in ar_data:
        ar_data[k] = k  # Will still show in English but no warning
        added += 1

# Also make sure all ar.json keys that equal their key (untranslated) get cleaned up
# Only flag ones that aren't dynamic
untranslated = [(k, v) for k, v in ar_data.items() if k == v and '{' not in k and '$' not in k and len(k) > 1]
print(f'Still untranslated in ar.json: {len(untranslated)}')
for k, v in untranslated[:30]:
    print(f'  {k}')

with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)
with open(ar_path, 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=2)

print(f'Added {added} missing keys. en.json now has {len(en_data)} keys.')
