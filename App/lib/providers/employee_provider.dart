import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:employee_app/config/app_config.dart';
import 'package:employee_app/models/employee_form_data.dart';
import 'package:employee_app/models/employee.dart';
import 'package:employee_app/services/employee_service.dart';
import 'package:flutter/foundation.dart';

enum EmployeeListFilter { all, active, flagged }

class EmployeeProvider extends ChangeNotifier {
  EmployeeProvider({EmployeeService? service})
      : _service = service ?? EmployeeService();

  final EmployeeService _service;
  final Connectivity _connectivity = Connectivity();

  List<Employee> _employees = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  int _total = 0;
  bool _hasMore = true;
  bool _isOffline = false;
  EmployeeListFilter _filter = EmployeeListFilter.all;
  EmployeeStats? _stats;
  Timer? _debounceTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get total => _stats?.total ?? _total;
  int get activeCount => _stats?.active ?? 0;
  int get flaggedCount => _stats?.flagged ?? 0;
  bool get hasMore => _hasMore;
  bool get isOffline => _isOffline;
  EmployeeListFilter get filter => _filter;

  String get _filterParam => switch (_filter) {
        EmployeeListFilter.active => 'active',
        EmployeeListFilter.flagged => 'flagged',
        EmployeeListFilter.all => 'all',
      };

  Future<void> initialize() async {
    if (_connectivitySubscription != null) return;

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
    );
    await _updateConnectivity(await _connectivity.checkConnectivity());
    await loadEmployees();
  }

  Future<void> _updateConnectivity(List<ConnectivityResult> results) async {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (_isOffline != offline) {
      _isOffline = offline;
      notifyListeners();
    }
  }

  Future<void> _loadStats() async {
    try {
      _stats = await _service.fetchStats();
    } catch (_) {
      // Stats are optional; list still works.
    }
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      await _loadStats();
      final result = await _service.fetchEmployees(
        search: _searchQuery,
        page: _currentPage,
        filter: _filterParam,
      );
      _employees = result.employees;
      _currentPage = result.currentPage;
      _total = result.total;
      _hasMore = result.currentPage < result.lastPage;
      _error = null;
    } catch (error) {
      _error = _formatError(error);
      if (_employees.isEmpty) _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _service.fetchEmployees(
        search: _searchQuery,
        page: _currentPage + 1,
        filter: _filterParam,
      );
      _employees = [..._employees, ...result.employees];
      _currentPage = result.currentPage;
      _total = result.total;
      _hasMore = result.currentPage < result.lastPage;
      _error = null;
    } catch (error) {
      _error = _formatError(error);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.trim();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConfig.debounceMs),
      loadEmployees,
    );
  }

  Future<void> refresh() => loadEmployees();

  void setFilter(EmployeeListFilter value) {
    if (_filter == value) return;
    _filter = value;
    loadEmployees();
  }

  Future<Employee> createEmployee(EmployeeFormData data) async {
    final employee = await _service.createEmployee(data);
    await loadEmployees();
    return employee;
  }

  Future<Employee> updateEmployee(int id, EmployeeFormData data) async {
    final employee = await _service.updateEmployee(id, data);
    await loadEmployees();
    return employee;
  }

  Future<void> deleteEmployee(int id) async {
    await _service.deleteEmployee(id);
    await loadEmployees();
  }

  String _formatError(Object error) {
    if (error is EmployeeServiceException) return error.message;
    return error.toString();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
