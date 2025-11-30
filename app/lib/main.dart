import 'package:flutter/material.dart';
import 'src/services/auth_service.dart';
import 'src/services/api_client.dart';
import 'ui/theme.dart';
import 'src/features/auth/login_screen.dart';
import 'src/features/admin/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Create a shared ApiClient that persists cookies and pass it into AuthService
  final api = await ApiClient.createWithCookiePersistence();
  final auth = AuthService(api: api);
  await auth.init();

  runApp(ValdiApp(auth: auth));
}

class ValdiApp extends StatelessWidget {
  final AuthService auth;
  const ValdiApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyBook BackOffice',
      theme: appTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: AuthGate(auth: auth),
    );
  }
}

class AuthGate extends StatelessWidget {
  final AuthService auth;
  const AuthGate({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    // React to auth changes using AnimatedBuilder (auth is a ChangeNotifier)
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        if (!auth.isSignedIn) return LoginScreen(auth: auth);
        // If signed in and an admin, show admin home
        if (auth.hasRole('ADMIN') || auth.isAdmin) return AdminHome(auth: auth);
        // Otherwise show regular Home
        return HomeScreen(auth: auth);
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AuthService auth;
  const HomeScreen({super.key, required this.auth});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use the same ApiClient instance that AuthService holds (includes cookie jar)
  String _status = 'idle';

  Future<void> _ping() async {
    setState(() => _status = 'loading');
    try {
      final code = await widget.auth.api.ping();
      setState(() => _status = 'HTTP $code');
    } on Exception catch (e) {
      setState(() => _status = 'error: $e');
    } catch (e) {
      setState(() => _status = 'error: $e');
    }
  }

  void _showResultDialog(String title, String body) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyBook BackOffice'),
        actions: [
          IconButton(
            onPressed: () async {
              await widget.auth.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome — project scaffold', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            Text('Auth ready: ${widget.auth.isSignedIn ? 'yes' : 'no'}'),
            const SizedBox(height: 6),
            if (widget.auth.currentUser != null) ...[
              Text('User: ${widget.auth.currentUser?.name ?? widget.auth.currentUser?.id}'),
              const SizedBox(height: 6),
              Text('Roles: ${widget.auth.currentUser?.roles.join(', ') ?? '-'}'),
            ],
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _ping, child: const Text('Ping API')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () async {
              try {
                final me = await widget.auth.api.me();
                _showResultDialog('Current /admin/auth/me', me.toString());
              } catch (e) {
                _showResultDialog('Who am I?', 'Error calling /admin/auth/me:\n$e');
              }
            }, child: const Text('Who am I?')),
            const SizedBox(height: 12),
            Text('Status: $_status'),
          ],
        ),
      ),
    );
  }
}
