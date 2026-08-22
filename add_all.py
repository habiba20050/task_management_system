# -*- coding: utf-8 -*-
import json

ar_path = 'w:/task_management_system/assets/lang/ar.json'
en_path = 'w:/task_management_system/assets/lang/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)
with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # Missing from console logs
    "COMPLAINTS": "الشكاوى",
    "Track and manage your team's complaints": "تتبع وادارة شكاوى فريقك",
    "Open": "مفتوح",
    "IT Services": "خدمات تقنية المعلومات",
    "Teams & Departments": "الفرق والاقسام",
    "Users & Roles": "المستخدمون والادوار",
    "Audit Logs": "سجلات التدقيق",
    "AUDIT LOGS": "سجلات التدقيق",
    "USERS ROLES": "المستخدمون والادوار",
    "Active Profiles": "الملفات الشخصية النشطة",
    "Admins & Managers": "المسؤولون والمديرون",
    "System Overview": "نظرة عامة على النظام",
    "Department Analytics": "تحليلات الاقسام",
    "Managers Analytics": "تحليلات المديرين",
    "Teams Analytics": "تحليلات الفرق",
    "User Type": "نوع المستخدم",
    "Whole Team": "الفريق بالكامل",
    "For Whom": "لمن",
    "Completion": "الانجاز",
    # Team names from mock data
    "Alpha Team": "فريق ألفا",
    "Beta Squad": "فريق بيتا",
    "Gamma Crew": "فريق جاما",
    "Delta Force": "فريق دلتا",
    "Omega Ops": "فريق اوميجا",
    # Common statuses/values that might come from data
    "Computer Science": "علوم الحاسوب",
    "Engineering": "الهندسة",
    "IT Services": "خدمات تقنية المعلومات",
    "Pending": "معلق",
    "Resolved": "تم الحل",
    "Closed": "مغلق",
    "Open": "مفتوح",
    "Under Investigation": "قيد التحقيق",
    "Escalated": "تم التصعيد",
    # Priority values
    "Low": "منخفض",
    "Medium": "متوسط",
    "High": "عالٍ",
    "Critical": "حرج",
    # Task statuses
    "Completed": "مكتمل",
    "In Progress": "قيد التنفيذ",
    "Overdue": "متأخر",
    "Not Started": "لم يبدأ",
    "Under Review": "قيد المراجعة",
    "Rejected": "مرفوض",
    "Approved": "تمت الموافقة",
    "Late": "متأخر",
    # Roles
    "Admin": "مدير النظام",
    "Manager": "مدير",
    "Team Leader": "قائد الفريق",
    "Team Member": "عضو الفريق",
    "Super Admin": "المسؤول الرئيسي",
    # More missing ones
    "REPORTS": "التقارير",
    "SETTINGS": "الاعدادات",
    "TEAM": "الفريق",
    "EVALUATIONS": "التقييمات",
    "REVIEW CENTER": "مركز المراجعة",
    "DASHBOARD": "لوحة التحكم",
    "TASKS": "المهام",
    # Sidebar navigation items
    "Dashboard": "لوحة التحكم",
    "Tasks": "المهام",
    "Reports": "التقارير",
    "Settings": "الاعدادات",
    "Complaints": "الشكاوى",
    "Evaluations": "التقييمات",
    "Review Center": "مركز المراجعة",
    "Teams": "الفرق",
    "Team": "الفريق",
    "Profile Settings": "اعدادات الحساب",
    "Logout": "تسجيل الخروج",
    "My Tasks": "مهامي",
    "Score & Achievements": "النقاط والانجازات",
}

# Add to ar.json (Arabic translations)
for k, v in new_translations.items():
    ar_data[k] = v

# Add to en.json (English = same as key)
for k in new_translations.keys():
    if k not in en_data:
        en_data[k] = k

with open(ar_path, 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=2)
with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)

print('Done! Added all missing translations.')
