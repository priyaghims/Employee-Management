import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/firestore_service.dart';
import '../widgets/employee_form.dart';

class EditEmployeePage extends StatelessWidget {
  final Employee employee;

  const EditEmployeePage({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Employee'),
        centerTitle: true,
      ),
      body: EmployeeForm(
        employee: employee,
        onSubmit: (Employee updatedEmployee) async {
          try {
            await firestoreService.updateEmployee(updatedEmployee);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${updatedEmployee.name} updated successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating employee: $e'),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

