import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../repositories/admin_repository.dart';

class UsersScreen extends StatelessWidget {
  final AuthService? auth;
  const UsersScreen({super.key, this.auth});

  @override
  Widget build(BuildContext context) {
    final repo = AdminRepository(api: auth?.api ?? ApiClient());
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: repo.fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No users found'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, i) {
              final u = items[i];
              return ListTile(
                title: Text(u['username']?.toString() ?? u['name']?.toString() ?? '—'),
                subtitle: Text(u['id']?.toString() ?? ''),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
