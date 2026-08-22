# -*- coding: utf-8 -*-
import re

# Read mock database file and extract all string literals that might be displayed
with open('w:/task_management_system/lib/core/network/mock_database.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Get all string values in the file (single-quoted strings)
strings = re.findall(r"'([A-Za-z][A-Za-z\s&/\-.,!?()]+)'", content)
unique = sorted(set(s.strip() for s in strings if len(s.strip()) > 2))
print(f'Found {len(unique)} unique strings in mock_database.dart')
for s in unique:
    print(repr(s))
