class CurrentUser {
  final String id;
  final String? name;
  final List<String> roles;

  CurrentUser({required this.id, this.name, required this.roles});

  factory CurrentUser.fromMap(Map<String, dynamic> map) {
    final idRaw = map['id'] ?? map['user_id'] ?? map['uuid'] ?? '';
    final id = idRaw.toString();
    final nameRaw = map['name'] ?? map['username'] ?? map['full_name'];
    final name = nameRaw?.toString();

    // Normalize into a list of lowercase role names for flexible checks
    final rolesRaw = map['roles'] ?? map['role'] ?? map['authorities'] ?? [];
    final roles = <String>[];
    if (rolesRaw is String) roles.add(rolesRaw.toLowerCase());
    if (rolesRaw is Iterable) roles.addAll(rolesRaw.map((e) => e.toString().toLowerCase()));

    return CurrentUser(id: id, name: name, roles: roles);
  }

  bool hasRole(String role) {
    final target = role.toLowerCase();
    for (final r in roles) {
      final normalized = r.replaceAll('-', '_');
      if (normalized == target) return true;
      // match substrings so super_admin or admin both match 'admin'
      if (normalized.contains(target)) return true;
      if (target.contains('admin') && normalized.contains('admin')) return true;
    }
    return false;
  }
}
