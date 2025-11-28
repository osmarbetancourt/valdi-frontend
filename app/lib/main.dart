import 'package:flutter/material.dart';
import 'src/services/auth_service.dart';
import 'src/services/api_client.dart';
import 'ui/theme.dart';
import 'src/features/auth/login_screen.dart';

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
        if (auth.isSignedIn) return HomeScreen(auth: auth);
        return LoginScreen(auth: auth);
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
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _ping, child: const Text('Ping API')),
            const SizedBox(height: 12),
            Text('Status: $_status'),
          ],
        ),
      ),
    );
  }
}
