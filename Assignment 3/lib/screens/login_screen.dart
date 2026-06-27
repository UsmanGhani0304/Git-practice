import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _rememberMe = false;
  bool _isFormValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final valid = _formKey.currentState?.validate() == true;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  Future<void> _login() async {
    if (!_isFormValid) return;

    final user = await widget.authController.login(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password.')),
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.dashboard,
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome Back',
      subtitle: 'Login with your registered account.',
      child: Form(
        key: _formKey,
        onChanged: _validateForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: _hidePassword,
              validator: (value) => Validators.requiredField(value, 'Password'),
              suffixIcon: IconButton(
                tooltip: _hidePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _hidePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _hidePassword = !_hidePassword),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remember Me'),
              value: _rememberMe,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) =>
                  setState(() => _rememberMe = value ?? false),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _isFormValid ? _login : null,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.registration,
              ),
              child: const Text('Create a new account'),
            ),
          ],
        ),
      ),
    );
  }
}
