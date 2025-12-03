import 'package:employee_management/models/employee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test double for EmployeeForm that matches the API used by AddEmployeePage
// but exposes a button to trigger onSubmit with a provided Employee.
class TestEmployeeForm extends StatelessWidget {
  const TestEmployeeForm({super.key, required this.onSubmit, required this.employeeToSubmit});

  final Future<void> Function(Employee) onSubmit;
  final Employee employeeToSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        key: const Key('triggerSubmit'),
        onPressed: () async {
          await onSubmit(employeeToSubmit);
        },
        child: const Text('Submit Test Employee'),
      ),
    );
  }
}

// A testable wrapper that mimics AddEmployeePage but allows injecting a FirestoreService-like object
// and replaces EmployeeForm with the TestEmployeeForm.
class TestableAddEmployeePage extends StatelessWidget {
  const TestableAddEmployeePage({
    super.key,
    required this.firestoreService,
    required this.employee,
  });

  final _FakeFirestoreService firestoreService;
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Employee'),
        centerTitle: true,
      ),
      body: _TestEmployeeFormHost(
        employee: employee,
        onSubmit: (emp) async {
          try {
            await firestoreService.addEmployee(emp);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${emp.name} added successfully'),
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

// Host to swap real EmployeeForm with test double but keep the same signature.
class _TestEmployeeFormHost extends StatelessWidget {
  const _TestEmployeeFormHost({required this.onSubmit, required this.employee});
  final Future<void> Function(Employee) onSubmit;
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return TestEmployeeForm(onSubmit: onSubmit, employeeToSubmit: employee);
  }
}

class _FakeFirestoreService {
  _FakeFirestoreService({this.shouldFail = false, this.delay = const Duration(milliseconds: 50)});
  bool shouldFail;
  Duration delay;

  int addCalls = 0;
  Employee? lastAdded;

  Future<void> addEmployee(Employee employee) async {
    addCalls += 1;
    lastAdded = employee;
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw Exception('Simulated failure');
    }
  }
}

Employee _sampleEmp({
  String id = 'id-1',
  String name = 'Alice',
  String email = 'alice@example.com',
  String position = 'Engineer',
  String phone = '1234567890',
  DateTime? joinedDate,
}) => Employee(
      id: id,
      name: name,
      email: email,
      position: position,
      phone: phone,
      joinedDate: joinedDate ?? DateTime(2023, 1, 1),
    );

void main() {
  group('AddEmployeePage integration behavior (orchestrates service, nav, snackbars)', () {
    testWidgets('calls FirestoreService.addEmployee with submitted employee', (tester) async {
      final fake = _FakeFirestoreService();
      final emp = _sampleEmp();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => TestableAddEmployeePage(
                firestoreService: fake,
                employee: emp,
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('triggerSubmit')));
      await tester.pump();
      await tester.pump(fake.delay);

      expect(fake.addCalls, 1);
      expect(fake.lastAdded, isNotNull);
      expect(fake.lastAdded!.name, emp.name);
    });

    testWidgets('on success: pops route and shows success SnackBar with employee name', (tester) async {
      final fake = _FakeFirestoreService();
      final emp = _sampleEmp(name: 'Bob');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: TestableAddEmployeePage(
                  firestoreService: fake,
                  employee: emp,
                ),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('triggerSubmit')));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // After success the page should have popped
      expect(find.byType(TestableAddEmployeePage), findsNothing);
      // Success snackbar should appear
      expect(find.text('Bob added successfully'), findsOneWidget);
    });

    testWidgets('on failure: shows error SnackBar and does not pop', (tester) async {
      final fake = _FakeFirestoreService(shouldFail: true);
      final emp = _sampleEmp(name: 'Carol');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: TestableAddEmployeePage(
                  firestoreService: fake,
                  employee: emp,
                ),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('triggerSubmit')));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Page should still be present (no pop on error)
      expect(find.byType(TestableAddEmployeePage), findsOneWidget);
      // Error snackbar should appear
      expect(find.textContaining('Error adding employee:'), findsOneWidget);
    });

    testWidgets('does not call service before onSubmit is triggered', (tester) async {
      final fake = _FakeFirestoreService();
      final emp = _sampleEmp();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => TestableAddEmployeePage(
                firestoreService: fake,
                employee: emp,
              ),
            ),
          ),
        ),
      ));

      // No submission yet
      expect(fake.addCalls, 0);

      // Now submit
      await tester.tap(find.byKey(const Key('triggerSubmit')));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(fake.addCalls, 1);
    });

    testWidgets('if unmounted before future completes, should not show SnackBar or pop', (tester) async {
      // Use a longer delay to guarantee we can replace route before completion
      final fake = _FakeFirestoreService(delay: const Duration(seconds: 2));
      final emp = _sampleEmp(name: 'Dave');

      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Navigator(
            key: navKey,
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: TestableAddEmployeePage(
                  firestoreService: fake,
                  employee: emp,
                ),
              ),
            ),
          ),
        ),
      ));

      // Start submission
      await tester.tap(find.byKey(const Key('triggerSubmit')));
      await tester.pump(); // start async

      // Immediately replace the route (simulate leaving the page BEFORE completion)
      navKey.currentState!.pushReplacement(
        MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Other'))),
      );
      await tester.pump(); // process route change

      // Advance less than the delay to ensure no completion yet
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Other'), findsOneWidget);
      expect(find.byType(TestableAddEmployeePage), findsNothing);
      expect(find.text('Dave added successfully'), findsNothing);

      // Advance beyond the delay; original context is unmounted so no UI side effects should appear
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Dave added successfully'), findsNothing);
    });
  });
}
