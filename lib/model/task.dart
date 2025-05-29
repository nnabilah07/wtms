class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String dateAssigned;
  final String dueDate;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dateAssigned,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(), 
      title: json['title'],
      description: json['description'],
      assignedTo: json['assigned_to'].toString(), 
      dateAssigned: json['date_assigned'],
      dueDate: json['due_date'],
      status: json['status'],
    );
  }
}
