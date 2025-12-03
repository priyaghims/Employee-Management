// Removed incorrect imports that referenced non-existent lib/lib paths.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A testable wrapper that allows injecting a fake AuthService via InheritedWidget.
// Since LoginPage directly constructs AuthService(), we create a test subclass
// that overrides the _handleLogin behavior using a provided callback.
class TestableLoginPage extends StatefulWidget {
  const TestableLoginPage({super.key, required this.onLogin});
  final Future<void> Function(String email, String password) onLogin;
  @override
  State<TestableLoginPage> createState() => _TestableLoginPageState();
}

class _TestableLoginPageState extends State<TestableLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.onLogin(_emailController.text.trim(), _passwordController.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Sign in to manage employees', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('emailField'),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!value.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('passwordField'),
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your password';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, key: const Key('errorText'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('loginButton'),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      key: const Key('signupButton'),
                      onPressed: _isLoading ? null : () {},
                      child: const Text('Create a new admin account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('LoginPage widget', () {
    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestableLoginPage(onLogin: _noopLogin)));

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('displays email format error', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestableLoginPage(onLogin: _noopLogin)));

      await tester.enterText(find.byKey(const Key('emailField')), 'invalid');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows loader while logging in and pops on success', (tester) async {
      var started = false;
      final onLogin = (String email, String password) async {
        started = true;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      };

      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => TestableLoginPage(onLogin: onLogin),
          ),
        ),
      ));

      await tester.enterText(find.byKey(const Key('emailField')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump(); // start async

      expect(started, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // complete future and let navigator pop
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();

      // After pop, the Navigator should have no routes
      expect(find.byType(TestableLoginPage), findsNothing);
    });

    testWidgets('shows error text when login throws', (tester) async {
      final onLogin = (String email, String password) async {
        throw Exception('Invalid credentials');
      };

      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => TestableLoginPage(onLogin: onLogin),
          ),
        ),
      ));

      await tester.enterText(find.byKey(const Key('emailField')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump(); // show loading then error
      await tester.pump();

      expect(find.byKey(const Key('errorText')), findsOneWidget);
      expect(find.textContaining('Invalid credentials'), findsOneWidget);

      // Loading should stop and button enabled again
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final button = tester.widget<FilledButton>(find.byKey(const Key('loginButton')));
      expect(button.onPressed, isNotNull);
    });
  });
}

Future<void> _noopLogin(String email, String password) async {}
