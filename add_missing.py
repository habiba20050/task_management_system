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
en_path = 'w:/task_management_system/assets/lang/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)
with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

missing = [k for k in keys_in_code if k not in ar_data]

for k in missing:
    ar_data[k] = k
    en_data[k] = k

with open(ar_path, 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=2)
with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)

print(f'Added {len(missing)} missing keys.')
print('Keys added (to translate):')
for k in missing:
    print(f'  {k}')
