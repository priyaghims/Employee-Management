import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/firestore_service.dart';
import '../widgets/employee_form.dart';

class AddEmployeePage extends StatelessWidget {
  const AddEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Employee'),
        centerTitle: true,
      ),
      body: EmployeeForm(
        onSubmit: (Employee employee) async {
          try {
            await firestoreService.addEmployee(employee);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${employee.name} added successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding employee: $e'),
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

