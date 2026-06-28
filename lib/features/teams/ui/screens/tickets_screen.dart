import 'package:flutter/material.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final List<String> _allTeams = ['Engineering Systems', 'UI/UX Design', 'Marketing', 'QA Testing'];
  final List<String> _selectedTeams = []; // لحفظ الفرق المختارة (Multi-select)
  
  String _searchQuery = "";
  String _selectedStatus = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tickets & Tasks Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 24),

            // شريط الفلاتر المتقدمة (البحث وتصفية الموظفين والفرق والحالة)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 1. البحث باسم الموظف أو المهمة
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: 'Search by Member name or Task...',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              prefixIcon: Icon(Icons.search, color: Color(0xFF0F4C81), size: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 2. التصفية بحالة الـ Task
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: ['All', 'Pending', 'In Progress', 'Completed']
                              .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedStatus = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. فلتر اختيار أكثر من فريق معاً (Multi-select Teams Filter)
                  const Text('Filter by Teams (Select Multiple):', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _allTeams.map((team) {
                      final isSelected = _selectedTeams.contains(team);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(team),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1E293B)),
                        selectedColor: const Color(0xFF0F4C81),
                        checkmarkColor: Colors.white,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedTeams.add(team);
                            } else {
                              _selectedTeams.remove(team);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // جدول عرض البيانات (مشابه لتصميم قائمة الـ Users)
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: ListView.separated(
                  itemCount: 5, // عدد تجريبي
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      leading: const CircleAvatar(backgroundColor: Color(0xFFE2E8F0), child: Icon(Icons.assignment, color: Color(0xFF0F4C81))),
                      title: Text('Task Specification Title #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            _buildInfoBadge('Member Name', Icons.person, const Color(0xFF64748B)),
                            const SizedBox(width: 12),
                            _buildInfoBadge('Engineering Systems', Icons.groups, const Color(0xFF0F4C81)),
                          ],
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: index % 2 == 0 ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          index % 2 == 0 ? 'Completed' : 'In Progress',
                          style: TextStyle(color: index % 2 == 0 ? const Color(0xFF065F46) : const Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}