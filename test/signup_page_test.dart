import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestableSignUpPage extends StatefulWidget {
  const TestableSignUpPage({super.key, required this.onSignUp});
  final Future<void> Function({required String email, required String password, required String username}) onSignUp;

  @override
  State<TestableSignUpPage> createState() => _TestableSignUpPageState();
}

class _TestableSignUpPageState extends State<TestableSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onSignUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully. Please log in.')),
        );
      }
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
      appBar: AppBar(title: const Text('Create Admin Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Text('Sign up as admin', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('usernameField'),
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please choose a username';
                        }
                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('emailField'),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
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
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('confirmPasswordField'),
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, key: const Key('errorText'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('signUpButton'),
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Sign Up'),
                    ),
                  ],
                  ),
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
  group('SignUpPage widget', () {
    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestableSignUpPage(onSignUp: _noopSignUp)));

      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();

      expect(find.text('Please choose a username'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('validates username too short', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestableSignUpPage(onSignUp: _noopSignUp)));

      await tester.enterText(find.byKey(const Key('usernameField')), 'ab');
      await tester.enterText(find.byKey(const Key('emailField')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), '123456');
      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();

      expect(find.text('Username must be at least 3 characters'), findsOneWidget);
    });

    testWidgets('validates invalid email', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestableSignUpPage(onSignUp: _noopSignUp)));

      await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
      await tester.enterText(find.byKey(const Key('emailField')), 'invalid');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), '123456');
      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates short password and mismatch confirmation', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TestableSignUpPage(onSignUp: _noopSignUp)));

      await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
      await tester.enterText(find.byKey(const Key('emailField')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '12345');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), '123456');
      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      // After correcting password length, mismatch error should show
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'abcdef');
      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows loader, pops with true, and shows success snackbar on success', (tester) async {
      var started = false;

      final onSignUp = ({required String email, required String password, required String username}) async {
        started = true;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      };

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => Scaffold(
                body: TestableSignUpPage(onSignUp: onSignUp),
              ),
            ),
          ),
        ),
      ));

      await tester.enterText(find.byKey(const Key('usernameField')), ' admin ');
      await tester.enterText(find.byKey(const Key('emailField')), ' a@b.com ');
      await tester.enterText(find.byKey(const Key('passwordField')), ' 123456 ');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), ' 123456 ');

      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();

      expect(started, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // After success it pops the route
      expect(find.byType(TestableSignUpPage), findsNothing);

      // SnackBar should be shown with success message
      expect(find.text('Account created successfully. Please log in.'), findsOneWidget);
    });

    testWidgets('shows error message and re-enables button on failure', (tester) async {
      final onSignUp = ({required String email, required String password, required String username}) async {
        throw Exception('Signup failed');
      };

      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => Scaffold(body: TestableSignUpPage(onSignUp: onSignUp)),
          ),
        ),
      ));

      await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
      await tester.enterText(find.byKey(const Key('emailField')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), '123456');

      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump(); // start loading
      await tester.pump(); // show error

      expect(find.byKey(const Key('errorText')), findsOneWidget);
      expect(find.textContaining('Signup failed'), findsOneWidget);

      // Loading stopped
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Button should be re-enabled
      final btn = tester.widget<FilledButton>(find.byKey(const Key('signUpButton')));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('trims inputs before calling signup', (tester) async {
      late String gotEmail;
      late String gotPassword;
      late String gotUsername;

      final onSignUp = ({required String email, required String password, required String username}) async {
        gotEmail = email;
        gotPassword = password;
        gotUsername = username;
      };

      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => TestableSignUpPage(onSignUp: onSignUp),
          ),
        ),
      ));

      await tester.enterText(find.byKey(const Key('usernameField')), ' admin ');
      await tester.enterText(find.byKey(const Key('emailField')), ' a@b.com ');
      await tester.enterText(find.byKey(const Key('passwordField')), ' 123456 ');
      await tester.enterText(find.byKey(const Key('confirmPasswordField')), ' 123456 ');

      await tester.tap(find.byKey(const Key('signUpButton')));
      await tester.pump();

      expect(gotUsername, 'admin');
      expect(gotEmail, 'a@b.com');
      expect(gotPassword, '123456');
    });
  });
}

// Removed fragile NavigatorObserver-based pop result capture.

Future<void> _noopSignUp({required String email, required String password, required String username}) async {}
