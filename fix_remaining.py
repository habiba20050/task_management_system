# -*- coding: utf-8 -*-
import json

ar_path = 'w:/task_management_system/assets/lang/ar.json'
with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

ar_data['#'] = '#'
ar_data['Submitted by: '] = '???? ??: '
ar_data['Priority: '] = '????????: '
ar_data['Estimated:  h'] = '??????:  ?'
ar_data[' task(s)'] = ' ????'
ar_data['Review completed successfully with status: '] = '??? ???????? ????? ???????: '
ar_data['Complaints Log ()'] = '??? ??????? ()'
ar_data[' selected'] = ' ????'

with open(ar_path, 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=2)

print('Done fixing remaining entries.')
