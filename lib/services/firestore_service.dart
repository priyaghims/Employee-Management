import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employees';

  // Add a new employee
  Future<void> addEmployee(Employee employee) async {
    try {
      await _firestore.collection(_collection).doc(employee.id).set(
            employee.toMap(),
          );
    } catch (e) {
      throw Exception('Error adding employee: $e');
    }
  }

  // Get real-time stream of all employees
  Stream<List<Employee>> getEmployeesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Employee.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get a single employee by ID
  Future<Employee?> getEmployeeById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Employee.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting employee: $e');
    }
  }

  // Update an existing employee
  Future<void> updateEmployee(Employee employee) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(employee.id)
          .update(employee.toMap());
    } catch (e) {
      throw Exception('Error updating employee: $e');
    }
  }

  // Delete an employee
  Future<void> deleteEmployee(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting employee: $e');
    }
  }
}

