# -*- coding: utf-8 -*-
import json

ar_path = 'w:/task_management_system/assets/lang/ar.json'
en_path = 'w:/task_management_system/assets/lang/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)
with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

# All strings that come from data/mock and need translation
data_translations = {
    # Navigation / Sidebar
    "Teams & Departments": "الفرق والاقسام",
    "Users & Roles": "المستخدمون والادوار",
    "Audit Logs": "سجلات التدقيق",
    "AUDIT LOGS": "سجلات التدقيق",
    "USERS ROLES": "ادوار المستخدمين",
    "COMPLAINTS": "الشكاوى",
    "Track and manage your team's complaints": "تتبع وادارة شكاوى فريقك",
    "Active Profiles": "الملفات النشطة",
    "Admins & Managers": "المسؤولون والمديرون",
    "System Overview": "نظرة عامة على النظام",
    "Department Analytics": "تحليلات الاقسام",
    "Managers Analytics": "تحليلات المديرين",
    "Teams Analytics": "تحليلات الفرق",
    "User Type": "نوع المستخدم",
    "Whole Team": "الفريق بالكامل",
    "For Whom": "لمن",
    "Completion": "الانجاز",
    "IT Services": "خدمات تقنية المعلومات",
    # Team names from mock data
    "Alpha Team": "فريق ألفا",
    "Beta Squad": "فريق بيتا",
    "Gamma Crew": "فريق جاما",
    "Delta Force": "فريق دلتا",
    "Omega Ops": "عمليات اوميجا",
    "Software Engineering Team": "فريق هندسة البرمجيات",
    "IT Infrastructure Team": "فريق البنية التحتية لتقنية المعلومات",
    "University Open Day Committee": "لجنة يوم الجامعة المفتوح",
    "Academic Quality Committee": "لجنة الجودة الاكاديمية",
    # Statuses from data
    "Open": "مفتوح",
    "Closed": "مغلق",
    "Submitted": "مُقدَّم",
    "Reopened": "اعيد فتحه",
    "Escalated": "تم التصعيد",
    # Modules/categories from mock data
    "Tasks": "المهام",
    "Complaints": "الشكاوى",
    "Evaluations": "التقييمات",
    "Departments": "الاقسام",
    "Teams": "الفرق",
    "Users": "المستخدمون",
    "Roles": "الادوار",
    "Reports": "التقارير",
    # Task types
    "Individual": "فردي",
    "Individual Task": "مهمة فردية",
    "Team Task": "مهمة جماعية",
    "Custom / Multiple": "مخصص / متعدد",
    "Other": "اخرى",
    # Priority (uppercase from data)
    "HIGH": "عالٍ",
    "MEDIUM": "متوسط",
    "LOW": "منخفض",
    # Complaint categories
    "Delay": "تاخير",
    "Workload Issue": "مشكلة عبء العمل",
    "Behavior": "السلوك",
    "Deadline Issue": "مشكلة الموعد النهائي",
    "Poor Quality": "جودة منخفضة",
    "Other": "اخرى",
    # Complaint sub-categories
    "Delayed deliverable submission": "تاخر تسليم المخرجات",
    "Excessive exam schedule tasks": "مهام جدول الامتحانات المفرطة",
    "Server maintenance timeline conflict": "تعارض في جدول صيانة الخادم",
    # Assignment modes
    "Whole Team": "الفريق بالكامل",
    # Permissions/operations
    "View Dashboard": "عرض لوحة التحكم",
    "View Tasks": "عرض المهام",
    "View Reports": "عرض التقارير",
    "View Teams": "عرض الفرق",
    "View Users": "عرض المستخدمين",
    "View Departments": "عرض الاقسام",
    "View Evaluations": "عرض التقييمات",
    "View Complaints": "عرض الشكاوى",
    "View Task Details": "عرض تفاصيل المهمة",
    "View Task History": "عرض سجل المهمة",
    "Create Task": "انشاء مهمة",
    "Edit Task": "تعديل مهمة",
    "Delete Task": "حذف مهمة",
    "Assign Task": "تعيين مهمة",
    "Reassign Task": "اعادة تعيين مهمة",
    "Complete Task": "اكمال مهمة",
    "Add Evaluation": "اضافة تقييم",
    "Edit Evaluation": "تعديل تقييم",
    "Add Department": "اضافة قسم",
    "Edit Department": "تعديل قسم",
    "Delete Department": "حذف قسم",
    "Add Team": "اضافة فريق",
    "Edit Team": "تعديل فريق",
    "Delete Team": "حذف فريق",
    "Add User": "اضافة مستخدم",
    "Edit User": "تعديل مستخدم",
    "Delete User": "حذف مستخدم",
    "Manage Roles": "ادارة الادوار",
    "Manage Permissions": "ادارة الصلاحيات",
    "Manage System Settings": "ادارة اعدادات النظام",
    "Export Reports": "تصدير التقارير",
    "Close Complaint": "اغلاق الشكوى",
    "Comment On Task": "التعليق على المهمة",
    "Task Assigned": "تم تعيين المهمة",
    "Task Created": "تم انشاء المهمة",
    "Task Overdue": "المهمة متاخرة",
    "Task Reassigned": "تم اعادة تعيين المهمة",
    "Submitted task deliverables": "تم تسليم مخرجات المهمة",
    # Departments
    "Computer Science": "علوم الحاسوب",
    "Engineering": "الهندسة",
    "Academic CS Dept": "قسم علوم الحاسوب الاكاديمي",
    "Academic ENG Dept": "قسم الهندسة الاكاديمي",
    # Task statuses
    "In Progress": "قيد التنفيذ",
    "Completed": "مكتمل",
    "Pending": "معلق",
    "Overdue": "متاخر",
    "Under Review": "قيد المراجعة",
    "Rejected": "مرفوض",
    "Approved": "تمت الموافقة",
    "Needs Changes": "يحتاج تعديلات",
    "Under Investigation": "قيد التحقيق",
    "Resolved": "تم الحل",
    "Active": "نشط",
    "Inactive": "غير نشط",
    "Assigned": "مخصص",
    # Roles
    "Admin": "مدير النظام",
    "Manager": "مدير",
    "Team Leader": "قائد الفريق",
    "Team Member": "عضو الفريق",
    "Super Admin": "المسؤول الرئيسي",
    "Member": "عضو",
    "Employee": "موظف",
    # Task priority
    "Low": "منخفض",
    "Medium": "متوسط",
    "High": "عالٍ",
    "Critical": "حرج",
    # Misc
    "Department Manager": "مدير القسم",
    "Department": "القسم",
    "Current Owner": "المالك الحالي",
    "System": "النظام",
    "System Root Administrator": "مدير النظام الجذري",
    "Status": "الحالة",
    "Reply": "رد",
    "Just now": "الآن",
    "Activity": "النشاط",
    "action": "إجراء",
    "Testing": "اختبار",
    "Communication": "التواصل",
    "Attendance": "الحضور",
    "Software / Code": "برمجيات / كود",
    "Hardware & Lab Maintenance": "صيانة الاجهزة والمختبر",
    # Evaluation fields
    "Productivity": "الانتاجية",
    "Teamwork": "العمل الجماعي",
    "Problem Solving": "حل المشكلات",
    "Quality": "الجودة",
    "Discipline": "الانضباط",
    # New ones from latest logs
    "Academic operations Admin": "مسؤول العمليات الاكاديمية",
    "Task delegator and coordinator": "منسق ومفوض المهام",
    "Active developer/researcher": "مطور/باحث نشط",
    "University IT support": "دعم تقنية المعلومات الجامعي",
}

for k, v in data_translations.items():
    ar_data[k] = v
    if k not in en_data:
        en_data[k] = k

with open(ar_path, 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=2)
with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)

print(f'Done! ar.json now has {len(ar_data)} keys')
