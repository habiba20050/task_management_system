class UnifiedItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final String priority;
  final String status;
  final String deadline;
  final String teamName;
  final String assignedTo;
  final dynamic originalObject;

  const UnifiedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.deadline,
    required this.teamName,
    required this.assignedTo,
    required this.originalObject,
  });
}
