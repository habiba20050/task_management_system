import 'package:flutter/material.dart';

class InviteUserDialogWidget extends StatefulWidget {
  const InviteUserDialogWidget({Key? key}) : super(key: key);

  // ميثود استاتيكية آمنة لفتح الـ Dialog من أي مكان بالتطبيق
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const InviteUserDialogWidget(),
    );
  }

  @override
  State<InviteUserDialogWidget> createState() => _InviteUserDialogWidgetState();
}

class _InviteUserDialogWidgetState extends State<InviteUserDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // حقول التحكم في النصوص والمدخلات
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        width: 500, // العرض المتناسق تماماً مع تصميم الـ Web/Tablet بالصورة
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey, // جعل المحتوى قابلاً للتمرير لمنع الـ Overflow
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. الهيدر (العنوان، الوصف، وزر الخروج X)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Invite New User',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Send a portal invitation to a new team member.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
          
                // 2. حقل الاسم الكامل (Full Name)
                _buildFieldLabel('Full Name *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                  decoration: _buildInputDecoration('e.g., Dr. Mona Said'),
                  validator: (val) => val!.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 20),
          
                // 3. حقل البريد الإلكتروني (Email Address)
                _buildFieldLabel('Email Address *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                  decoration: _buildInputDecoration('user@aitu.edu.eg'),
                  validator: (val) => val!.isEmpty ? 'Email address is required' : null,
                ),
                const SizedBox(height: 20),
          
                // 4. حقل تعيين الدور (Assign Role)
                _buildFieldLabel('Assign Role'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  hint: const Text('Select a role', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                  decoration: _buildInputDecoration(''),
                  items: ['Admin', 'Manager', 'Member']
                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRole = val),
                ),
                const SizedBox(height: 20),
          
                // 5. حقل القسم (Department)
                _buildFieldLabel('Department'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _departmentController,
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                  decoration: _buildInputDecoration(''),
                ),
                const SizedBox(height: 32),
          
                // 6. أزرار التحكم السفلية (Cancel & Send Invitation)
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
                          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // التحقق من صحة الحقول أولاً لمنع الأخطاء اللحظية
                          if (_formKey.currentState!.validate()) {
                            // تخرين مرجع الـ Navigator لحماية السياق (Context) من التضارب والـ Assertion Error
                            final navigator = Navigator.of(context);
                            
                            // هنا يتم وضع منطق استدعاء الـ Cubit مستقبلاً، مثل:
                            // context.read<UsersCubit>().inviteUser(...);
                            
                            // الإغلاق الآمن للـ Dialog
                            navigator.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C81), // اللون الكحلي المطابق للتصميم تماماً
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Send Invitation',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويجت مخصصة لعناوين الحقول لتوحيد حجم ولون الخط
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  // تصميم موحد للـ Borders باللون الأبيض الصافي والحواف الدائرية الخفيفة
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
      ),
    );
  }
}