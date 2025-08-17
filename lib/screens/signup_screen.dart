// Sign up screen for new users
// Written by: Aytan (Intern)

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _nameCtl.dispose();
    super.dispose();
  }

  // Handles sign up logic
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.signUp(
        email: _emailCtl.text.trim(),
        password: _passCtl.text.trim(),
        displayName: _nameCtl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtl,
                        decoration: const InputDecoration(
                          labelText: 'Full name (optional)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtl,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.length < 6) ? '6+ chars' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ElevatedButton(
                        onPressed: _loading ? null : _signup,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
