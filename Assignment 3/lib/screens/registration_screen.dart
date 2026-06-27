import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../enums/gender.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Gender? _gender;
  bool _isFormValid = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final valid = _formKey.currentState?.validate() == true && _gender != null;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    await widget.authController.registerUser(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      gender: _gender!,
      password: _passwordController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration successful. Please login.')),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Register to continue to your student dashboard.',
      child: Form(
        key: _formKey,
        onChanged: _validateForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _firstNameController,
              label: 'First Name',
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.requiredField(value, 'First name'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _lastNameController,
              label: 'Last Name',
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.requiredField(value, 'Last name'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<Gender>(
              value: _gender,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: Gender.values
                  .map(
                    (gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender.label),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Gender selection is required' : null,
              onChanged: (value) {
                setState(() => _gender = value);
                _validateForm();
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              validator: Validators.password,
              suffixIcon: IconButton(
                tooltip: _hidePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _hidePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _hidePassword = !_hidePassword),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: _hideConfirmPassword,
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              suffixIcon: IconButton(
                tooltip: _hideConfirmPassword
                    ? 'Show confirm password'
                    : 'Hide confirm password',
                icon: Icon(
                  _hideConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () => setState(
                  () => _hideConfirmPassword = !_hideConfirmPassword,
                ),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _isFormValid ? _submit : null,
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
