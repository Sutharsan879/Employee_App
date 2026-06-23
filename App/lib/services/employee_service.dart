import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:employee_app/config/app_config.dart';
import 'package:employee_app/models/employee_form_data.dart';
import 'package:employee_app/models/employee.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmployeeServiceException implements Exception {
  EmployeeServiceException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => message;
}

class EmployeeListResult {
  const EmployeeListResult({
    required this.employees,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<Employee> employees;
  final int currentPage;
  final int lastPage;
  final int total;
}

class EmployeeStats {
  const EmployeeStats({
    required this.total,
    required this.active,
    required this.flagged,
  });

  final int total;
  final int active;
  final int flagged;

  factory EmployeeStats.fromJson(Map<String, dynamic> json) {
    return EmployeeStats(
      total: (json['total'] as num).toInt(),
      active: (json['active'] as num).toInt(),
      flagged: (json['flagged'] as num).toInt(),
    );
  }
}

class EmployeeService {
  EmployeeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw EmployeeServiceException(
        'API_BASE_URL is missing. Rebuild after editing assets/.env.',
      );
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<EmployeeListResult> fetchEmployees({
    String search = '',
    int page = 1,
    String filter = 'all',
  }) async {
    final query = <String, String>{
      'page': '$page',
      if (search.isNotEmpty) 'search': search,
      if (filter != 'all') 'filter': filter,
    };

    final uri = Uri.parse('$baseUrl/employees').replace(queryParameters: query);

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: AppConfig.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        final meta = body['meta'] as Map<String, dynamic>? ?? {};

        return EmployeeListResult(
          employees: data
              .map((item) => Employee.fromJson(item as Map<String, dynamic>))
              .toList(),
          currentPage: (meta['current_page'] as num?)?.toInt() ?? page,
          lastPage: (meta['last_page'] as num?)?.toInt() ?? page,
          total: (meta['total'] as num?)?.toInt() ?? data.length,
        );
      }

      throw EmployeeServiceException(
        _extractErrorMessage(response.body) ??
            'Server returned HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw EmployeeServiceException(_connectionHelpMessage());
    } on TimeoutException {
      throw EmployeeServiceException(
        'Request timed out. Check Wi-Fi and Laravel server.',
      );
    } catch (error) {
      if (error is EmployeeServiceException) rethrow;
      throw EmployeeServiceException('Could not load employees.');
    }
  }

  Future<EmployeeStats> fetchStats() async {
    final uri = Uri.parse('$baseUrl/employees/stats');
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: AppConfig.requestTimeoutSeconds));

    if (response.statusCode == 200) {
      return EmployeeStats.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw EmployeeServiceException('Could not load employee statistics.');
  }

  Future<Employee> fetchEmployee(int id) async {
    final uri = Uri.parse('$baseUrl/employees/$id');
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: AppConfig.requestTimeoutSeconds));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body.containsKey('data')
          ? body['data'] as Map<String, dynamic>
          : body;
      return Employee.fromJson(data);
    }

    if (response.statusCode == 404) {
      throw EmployeeServiceException('Employee not found.', statusCode: 404);
    }

    throw EmployeeServiceException('Failed to load employee.');
  }

  Future<Employee> createEmployee(EmployeeFormData data) async {
    return _mutateEmployee(
      method: 'POST',
      uri: Uri.parse('$baseUrl/employees'),
      body: data.toApiPayload(),
    );
  }

  Future<Employee> updateEmployee(int id, EmployeeFormData data) async {
    return _mutateEmployee(
      method: 'PUT',
      uri: Uri.parse('$baseUrl/employees/$id'),
      body: data.toApiPayload(),
    );
  }

  Future<void> deleteEmployee(int id) async {
    final response = await _client
        .delete(
          Uri.parse('$baseUrl/employees/$id'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: AppConfig.requestTimeoutSeconds));

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 404) {
      throw EmployeeServiceException('Employee not found.', statusCode: 404);
    }

    throw EmployeeServiceException(
      _extractErrorMessage(response.body) ?? 'Failed to delete employee.',
      statusCode: response.statusCode,
    );
  }

  Future<Employee> _mutateEmployee({
    required String method,
    required Uri uri,
    required Map<String, dynamic> body,
  }) async {
    try {
      final encoded = jsonEncode(body);
      final headers = const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final http.Response response;
      if (method == 'POST') {
        response = await _client
            .post(uri, headers: headers, body: encoded)
            .timeout(const Duration(seconds: AppConfig.requestTimeoutSeconds));
      } else {
        response = await _client
            .put(uri, headers: headers, body: encoded)
            .timeout(const Duration(seconds: AppConfig.requestTimeoutSeconds));
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded.containsKey('data')
            ? decoded['data'] as Map<String, dynamic>
            : decoded;
        return Employee.fromJson(data);
      }

      if (response.statusCode == 422) {
        throw _validationException(response.body);
      }

      throw EmployeeServiceException(
        _extractErrorMessage(response.body) ?? 'Request failed.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw EmployeeServiceException(_connectionHelpMessage());
    } on TimeoutException {
      throw EmployeeServiceException('Request timed out.');
    }
  }

  EmployeeServiceException _validationException(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final errorsRaw = decoded['errors'] as Map<String, dynamic>? ?? {};
      final fieldErrors = errorsRaw.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => e.toString()).toList(),
        ),
      );
      final first = fieldErrors.values
          .expand((messages) => messages)
          .cast<String>()
          .firstOrNull;
      return EmployeeServiceException(
        first ?? (decoded['message'] as String? ?? 'Validation failed.'),
        statusCode: 422,
        fieldErrors: fieldErrors,
      );
    } catch (_) {
      return EmployeeServiceException('Validation failed.', statusCode: 422);
    }
  }

  String _connectionHelpMessage() => 'Cannot reach server at $baseUrl';

  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return decoded['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
