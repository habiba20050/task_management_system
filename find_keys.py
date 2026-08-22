import os
import re
import json

dart_files = []
for root, _, files in os.walk('w:/task_management_system/lib'):
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

pattern = re.compile(r'\'([^\']+)\'\.tr\([^)]*\)|\"([^\"]+)\"\.tr\([^)]*\)')

keys_in_code = set()
for file_path in dart_files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        matches = pattern.findall(content)
        for m in matches:
            key = m[0] if m[0] else m[1]
            keys_in_code.add(key)

print(f'Found {len(keys_in_code)} keys in code.')

en_path = 'w:/task_management_system/assets/lang/en.json'
ar_path = 'w:/task_management_system/assets/lang/ar.json'

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)
with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

missing_en = [k for k in keys_in_code if k not in en_data]
missing_ar = [k for k in keys_in_code if k not in ar_data]

if len(missing_en) > 0:
    for k in missing_en:
        en_data[k] = k
        ar_data[k] = k # Temporary assign English to Arabic

    with open(en_path, 'w', encoding='utf-8') as f:
        json.dump(en_data, f, ensure_ascii=False, indent=2)
    with open(ar_path, 'w', encoding='utf-8') as f:
        json.dump(ar_data, f, ensure_ascii=False, indent=2)

print('Added missing keys.')
