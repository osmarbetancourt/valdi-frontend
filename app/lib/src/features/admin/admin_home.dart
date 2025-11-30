import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'businesses_screen.dart';
import 'users_screen.dart';
import 'payments_screen.dart';
import 'metabase_embed_screen.dart';

class AdminHome extends StatelessWidget {
  final AuthService auth;
  const AdminHome({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin — BackOffice'),
        actions: [
          IconButton(
              onPressed: () async {
                await auth.signOut();
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin dashboard', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Tile(title: 'Businesses', icon: Icons.business, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessesScreen(auth: auth)))),
                _Tile(title: 'Users', icon: Icons.people, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UsersScreen(auth: auth)))),
                _Tile(title: 'Payments', icon: Icons.payments, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentsScreen(auth: auth)))),
                _Tile(title: 'Embeds', icon: Icons.dashboard, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetabaseEmbedScreen()))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _Tile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 160,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28),
                const Spacer(),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
