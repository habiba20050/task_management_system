import 'package:flutter/material.dart';
import '../../model/user_role_model.dart';

class EditUserDialogWidget extends StatefulWidget {
  final UserRoleModel user;

  const EditUserDialogWidget({Key? key, required this.user}) : super(key: key);

  static void show(BuildContext context, UserRoleModel user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditUserDialogWidget(user: user),
    );
  }

  @override
  State<EditUserDialogWidget> createState() => _EditUserDialogWidgetState();
}

class _EditUserDialogWidgetState extends State<EditUserDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _departmentController;
  String? _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    // ملء الحقول تلقائياً ببيانات المستخدم الحالية
    _fullNameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _departmentController = TextEditingController(text: widget.user.department);
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

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
      backgroundColor: Colors.white,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit User Details',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // حقل الاسم
              _buildFieldLabel('Full Name *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                decoration: _buildInputDecoration(''),
                validator: (val) => val!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),

              // حقل البريد
              _buildFieldLabel('Email Address *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration(''),
                validator: (val) => val!.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 20),

              // حقل الدور
              _buildFieldLabel('Role'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _buildInputDecoration(''),
                items: ['Admin', 'Manager', 'Member']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
              ),
              const SizedBox(height: 20),

              // حقل القسم
              _buildFieldLabel('Department'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _departmentController,
                decoration: _buildInputDecoration(''),
              ),
              const SizedBox(height: 20),

              // حقل الحالة (Active / Inactive) ت切り替え
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('Account Status (Active)'),
                  Switch(
                    value: _isActive,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // أزرار التحكم وحماية الـ Context التاريخي للـ Navigator
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final navigator = Navigator.of(context);
                          // هنا يمكنك استدعاء دالة التحديث في الـ Cubit مستقبلاً:
                          // context.read<UsersCubit>().updateUser(...);
                          navigator.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C81),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildFieldLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)));
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5)),
    );
  }
}