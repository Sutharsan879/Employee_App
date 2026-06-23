import 'package:employee_app/config/app_config.dart';
import 'package:flutter/material.dart';

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.phone,
    required this.joiningDate,
    required this.isActive,
    required this.yearsOfService,
    required this.isFlagged,
    required this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  final String department;
  final String designation;
  final String? phone;
  final DateTime joiningDate;
  final bool isActive;
  final int yearsOfService;
  final bool isFlagged;
  final String? avatarUrl;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      department: json['department'] as String,
      designation: json['designation'] as String,
      phone: json['phone'] as String?,
      joiningDate: DateTime.parse(json['joining_date'] as String),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      yearsOfService: (json['years_of_service'] as num).toInt(),
      isFlagged: json['is_flagged'] == true || json['is_flagged'] == 1,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'designation': designation,
      'phone': phone,
      'joining_date': joiningDate.toIso8601String().split('T').first,
      'is_active': isActive,
      'years_of_service': yearsOfService,
      'is_flagged': isFlagged,
      'avatar_url': avatarUrl,
    };
  }

  Color get flagColor => isFlagged ? AppColors.flagGreen : Colors.white;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
