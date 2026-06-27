import 'package:flutter/material.dart';

class CreateTeamDialogWidget extends StatefulWidget {
  const CreateTeamDialogWidget({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CreateTeamDialogWidget(),
    );
  }

  @override
  State<CreateTeamDialogWidget> createState() => _CreateTeamDialogWidgetState();
}

class _CreateTeamDialogWidgetState extends State<CreateTeamDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // التحكم في نصوص المدخلات
  final _teamNameController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedLeader;
  String? _selectedMember;

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        width: 550, // تحديد عرض متناسق تماماً مع تصميم الـ Web/Tablet بالصورة
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الهيدر (العنوان وزر الإغلاق X)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Create New Team',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Set up a new team and assign a leader.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), thickness: 1),
              const SizedBox(height: 24),

              // 2. حقل اسم الفريق (Team Name)
              _buildFieldLabel('Team Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _teamNameController,
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                decoration: _buildInputDecoration('e.g., Web Development Team'),
              ),
              const SizedBox(height: 24),

              // 3. حقل القسم (Department Dropdown)
              _buildFieldLabel('Department'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                hint: const Text('e.g., CS Department', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                decoration: _buildInputDecoration(''),
                items: ['CS Department', 'IS Department', 'Engineering Dept']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedDepartment = val),
              ),
              const SizedBox(height: 24),

              // 4. حقل قائد الفريق (Team Leader Dropdown)
              _buildFieldLabel('Team Leader'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLeader,
                hint: const Text('Search for a team member...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                decoration: _buildInputDecoration(''),
                items: ['Prof. Khalid Mansour', 'Dr. Ali Rashed']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedLeader = val),
              ),
              const SizedBox(height: 24),

              // 5. حقل الأعضاء (Member Dropdown)
              _buildFieldLabel('Member'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMember,
                hint: const Text('Search for a member...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                decoration: _buildInputDecoration(''),
                items: ['Ahmed Hamada', 'Mohamed Ali', 'Doha Mohamed']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedMember = val),
              ),
              const SizedBox(height: 36),

              // 6. أزرار التحكم السفلية (Cancel & Create Team)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // تنفيذ منطق الإضافة هنا (Cubit Call)
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81), // نفس اللون الأزرق الداكن بالتصميم
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create Team',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ويجت مخصصة لعناوين الحقول لتوحيد الـ Style وحجم الخط
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  // ستايل موحد لجميع حقول الإدخال والـ Dropdowns لمطابقة خلفية التصميم الرمادية الفاتحة وبدون حدود حادة
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      fillColor: const Color(0xFFEDF2F7), // لون الخلفية الرمادي الفاتح للحقول
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1),
      ),
    );
  }
}