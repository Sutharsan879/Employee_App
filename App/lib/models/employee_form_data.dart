class EmployeeFormData {
  const EmployeeFormData({
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.joiningDate,
    required this.isActive,
    this.phone,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String department;
  final String designation;
  final String? phone;
  final DateTime joiningDate;
  final bool isActive;
  final String? avatarUrl;

  Map<String, dynamic> toApiPayload() {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'department': department,
      'designation': designation,
      'joining_date': _formatDate(joiningDate),
      'is_active': isActive,
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
      if (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
        'avatar_url': avatarUrl!.trim(),
    };
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class EmployeeFormOptions {
  EmployeeFormOptions._();

  static const departments = [
    'Engineering',
    'HR',
    'Marketing',
    'Finance',
    'Operations',
    'Sales',
  ];

  static List<String> withCurrent(List<String> options, String? current) {
    if (current == null || current.isEmpty || options.contains(current)) {
      return options;
    }
    return [current, ...options];
  }
}
