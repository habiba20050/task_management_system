import os
import re
import json

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

ar_path = 'w:/task_management_system/assets/lang/ar.json'
with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

missing_ar = [k for k in keys_in_code if k not in ar_data]
untranslated = [k for k, v in ar_data.items() if k == v]

print(f'Total keys in code: {len(keys_in_code)}')
print(f'Missing from ar.json: {len(missing_ar)}')
print(f'Untranslated (same as key): {len(untranslated)}')

if missing_ar:
    print('Missing keys:')
    for k in missing_ar:
        print(f'  - {k}')

if untranslated:
    print('Still untranslated:')
    for k in untranslated[:20]:
        print(f'  - {k}')
