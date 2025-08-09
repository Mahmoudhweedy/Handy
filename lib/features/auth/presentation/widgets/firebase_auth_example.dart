import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/providers/auth_provider.dart';
import '../../../../common/widgets/app_button.dart';
import '../../../../common/widgets/app_text_field.dart';

/// Example authentication widget demonstrating Firebase integration
class FirebaseAuthExample extends ConsumerStatefulWidget {
  const FirebaseAuthExample({super.key});

  @override
  ConsumerState<FirebaseAuthExample> createState() =>
      _FirebaseAuthExampleState();
}

class _FirebaseAuthExampleState extends ConsumerState<FirebaseAuthExample> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: authState.isAuthenticated
            ? _buildAuthenticatedContent(authState)
            : _buildAuthForm(),
      ),
    );
  }

  Widget _buildAuthenticatedContent(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Email: ${authState.user?.email ?? 'Unknown'}'),
                Text(
                  'Name: ${authState.user?.firstName} ${authState.user?.lastName}',
                ),
                Text(
                  'Email Verified: ${authState.user?.isEmailVerified ?? false}',
                ),
                Text(
                  'Created: ${authState.user?.createdAt.toString().split(' ')[0] ?? 'Unknown'}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AppButton.elevated(
          text: 'Sign Out',
          onPressed: authState.isLoading
              ? null
              : () => ref.read(authProvider.notifier).signOut(),
          isLoading: authState.isLoading,
        ),
        const SizedBox(height: 16),
        AppButton.outlined(
          text: 'Send Password Reset Email',
          onPressed: authState.isLoading ? null : () => _sendPasswordReset(),
        ),
        const SizedBox(height: 16),
        AppButton.outlined(
          text: 'Change Password',
          onPressed: authState.isLoading
              ? null
              : () => _showChangePasswordDialog(),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isSignUp ? 'Create Account' : 'Sign In',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          if (_isSignUp) ...[
            AppTextField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'Enter your first name',
              validator: (value) =>
                  value?.isEmpty == true ? 'First name is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'Enter your last name',
              validator: (value) =>
                  value?.isEmpty == true ? 'Last name is required' : null,
            ),
            const SizedBox(height: 16),
          ],

          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            type: AppTextFieldType.email,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email is required';
              if (!RegExp(
                r'^[\\w\\.-]+@[\\w\\.-]+\\.\\w+\$',
              ).hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            type: AppTextFieldType.password,
            validator: (value) {
              if (value?.isEmpty == true) return 'Password is required';
              if (value!.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          AppButton.elevated(
            text: _isSignUp ? 'Sign Up' : 'Sign In',
            onPressed: authState.isLoading ? null : _handleSubmit,
            isLoading: authState.isLoading,
          ),
          const SizedBox(height: 16),

          AppButton.outlined(
            text: 'Sign In with Google',
            onPressed: authState.isLoading ? null : _signInWithGoogle,
            icon: Icons.login,
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: authState.isLoading
                ? null
                : () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign In'
                  : 'Don\'t have an account? Sign Up',
            ),
          ),

          if (authState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                authState.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);

    if (_isSignUp) {
      notifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
    } else {
      notifier.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _signInWithGoogle() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send password reset email: $e')),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: currentPasswordController,
              label: 'Current Password',
              type: AppTextFieldType.password,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: newPasswordController,
              label: 'New Password',
              type: AppTextFieldType.password,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Change',
            onPressed: () async {
              try {
                await ref
                    .read(authProvider.notifier)
                    .changePassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                    );
                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to change password: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
