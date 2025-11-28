import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' show DioException;
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService auth;
  const LoginScreen({super.key, required this.auth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _pressed = false;
  bool _success = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final token = await widget.auth.loginRequest(_usernameCtrl.text.trim(), _passwordCtrl.text);
      if (token.isEmpty) {
        setState(() => _errorMessage = 'Login succeeded but no token returned');
        return;
      }

      // show success animation then complete sign-in
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 700));
      await widget.auth.finishSignIn(token);
      // AuthGate will switch to Home
    } catch (e) {
      String message = 'Login failed';
      // Friendly handling for Dio errors (401 -> invalid credentials)
      if (e is DioException) {
        final code = e.response?.statusCode;
        if (code == 401) {
          message = 'Invalid username or password';
        } else if (e.response?.data is Map && e.response!.data['message'] != null) {
          message = e.response!.data['message'].toString();
        } else if (code != null) {
          message = 'Server returned HTTP $code';
        } else {
          message = 'Network error — please try again';
        }
      } else {
        message = e.toString();
      }
      setState(() {
        _errorMessage = message;
        _success = false;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo + title
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: isDark ? Colors.white12 : Colors.white,
                    child: ClipOval(
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: CachedNetworkImage(
                          imageUrl: 'https://pub-a361f1bb745a47b9b0a8364c5790d8d5.r2.dev/moneybook_upscaled.jpeg',
                          fit: BoxFit.cover,
                          errorWidget: (c, u, e) => const Icon(Icons.business, size: 42),
                          placeholder: (c, u) => const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('MoneyBook BackOffice', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Accede al BackOffice de Mercedes', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 18),

                  // Login card (animated on press)
                  GestureDetector(
                    onTapDown: (_) => setState(() => _pressed = true),
                    onTapUp: (_) => setState(() => _pressed = false),
                    onTapCancel: () => setState(() => _pressed = false),
                    child: AnimatedScale(
                      scale: _pressed ? 0.995 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: isDark ? 8 : 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _usernameCtrl,
                              decoration: const InputDecoration(labelText: 'Usuario', hintText: 'tu.usuario@empresa.com'),
                              validator: (v) => (v ?? '').isEmpty ? 'Enter username' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v ?? '').isEmpty ? 'Enter password' : null,
                            ),
                            const SizedBox(height: 18),

                            // Gradient button — wrapped in Material to show ripple
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: Material(
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: _loading ? null : _submit,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: isDark
                                          ? [const Color(0xFF00C2B1), const Color(0xFF00A7F7)]
                                          : [const Color(0xFF006D77), const Color(0xFF00B3C6)]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 250),
                                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                        child: _success
                                            ? const Icon(Icons.check_circle, key: ValueKey('success'), color: Colors.white, size: 22)
                                            : _loading
                                                ? const SizedBox(key: ValueKey('loading'), width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                : const Text('Entrar', key: ValueKey('label'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            if (_errorMessage != null) ...[
                              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              const SizedBox(height: 8),
                            ],
                            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('¿Olvidaste tu contraseña?'))),
                          ],
                        ),
                      ),
                    ),
                    ),
                    ),
                    ),

                    const SizedBox(height: 12),
                  Text('Use your admin credentials to sign in.', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
