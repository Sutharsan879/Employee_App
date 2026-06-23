import 'package:employee_app/config/app_config.dart';
import 'package:employee_app/models/employee.dart';
import 'package:employee_app/models/employee_form_data.dart';
import 'package:employee_app/providers/employee_provider.dart';
import 'package:employee_app/services/employee_service.dart';
import 'package:employee_app/widgets/form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key, this.employee});

  /// Null = add mode; non-null = edit mode.
  final Employee? employee;

  bool get isEdit => employee != null;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;

  String? _department;
  late final TextEditingController _designationController;
  DateTime? _joiningDate;
  bool _isActive = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameController = TextEditingController(text: e?.name ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _avatarController = TextEditingController(text: e?.avatarUrl ?? '');
    _designationController =
        TextEditingController(text: e?.designation ?? '');
    _department = e?.department ?? EmployeeFormOptions.departments.first;
    _joiningDate = e?.joiningDate ?? DateTime.now();
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _joiningDate == null) {
      if (_joiningDate == null) {
        setState(() => _errorMessage = 'Please select a joining date.');
      }
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final data = EmployeeFormData(
      name: _nameController.text,
      email: _emailController.text,
      department: _department!,
      designation: _designationController.text,
      phone: _phoneController.text,
      joiningDate: _joiningDate!,
      isActive: _isActive,
      avatarUrl: _avatarController.text,
    );

    try {
      final provider = context.read<EmployeeProvider>();
      if (widget.isEdit) {
        await provider.updateEmployee(widget.employee!.id, data);
      } else {
        await provider.createEmployee(data);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit ? 'Employee updated' : 'Employee added',
            ),
            backgroundColor: AppColors.flagGreen,
          ),
        );
      }
    } on EmployeeServiceException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _joiningDate != null
        ? DateFormat('MMM d, yyyy').format(_joiningDate!)
        : 'Select date';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Employee' : 'Add Employee'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppText.caption.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            FormSectionCard(
              title: 'Personal',
              children: [
                AppFormField(
                  controller: _nameController,
                  label: 'Full name',
                  hint: 'John Doe',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                AppFormField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'john@company.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                AppFormField(
                  controller: _phoneController,
                  label: 'Phone (optional)',
                  hint: '+91 9876543210',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            FormSectionCard(
              title: 'Work',
              children: [
                AppDropdownField(
                  label: 'Department',
                  value: _department,
                  items: EmployeeFormOptions.withCurrent(
                    EmployeeFormOptions.departments,
                    widget.employee?.department,
                  ),
                  onChanged: (v) => setState(() => _department = v),
                  validator: (v) => v == null ? 'Select department' : null,
                ),
                AppFormField(
                  controller: _designationController,
                  label: 'Designation',
                  hint: 'Senior Developer',
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Designation is required'
                      : null,
                ),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Joining date',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      dateLabel,
                      style: AppText.body.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Active employee',
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Inactive employees are not flagged',
                    style: AppText.micro.copyWith(color: AppColors.textSecondary),
                  ),
                  value: _isActive,
                  activeThumbColor: AppColors.flagGreen,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
            FormSectionCard(
              title: 'Optional',
              children: [
                AppFormField(
                  controller: _avatarController,
                  label: 'Avatar URL',
                  hint: 'https://...',
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(widget.isEdit ? Icons.save_outlined : Icons.person_add_outlined),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : widget.isEdit
                          ? 'Save Changes'
                          : 'Add Employee',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
