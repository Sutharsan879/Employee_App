import 'package:employee_app/models/employee.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Employee', () {
    test('fromJson parses flagged active veteran correctly', () {
      final employee = Employee.fromJson({
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'department': 'Engineering',
        'designation': 'Senior Developer',
        'phone': '+91 9876543210',
        'joining_date': '2017-03-15',
        'is_active': true,
        'years_of_service': 8,
        'is_flagged': true,
        'avatar_url': null,
      });

      expect(employee.isFlagged, isTrue);
      expect(employee.yearsOfService, 8);
      expect(employee.initials, 'JD');
    });

    test('fromJson parses non-flagged employee correctly', () {
      final employee = Employee.fromJson({
        'id': 2,
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'department': 'HR',
        'designation': 'Junior Associate',
        'phone': null,
        'joining_date': '2023-01-10',
        'is_active': true,
        'years_of_service': 2,
        'is_flagged': false,
        'avatar_url': null,
      });

      expect(employee.isFlagged, isFalse);
      expect(employee.initials, 'JS');
    });
  });
}
