enum UserRole { customer, staff, admin }

UserRole roleFromString(String role) {
  switch (role) {
    case 'admin':
      return UserRole.admin;
    case 'staff':
      return UserRole.staff;
    default:
      return UserRole.customer;
  }
}

String roleToLabel(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'Administrator';
    case UserRole.staff:
      return 'Store Staff';
    case UserRole.customer:
      return 'Customer';
  }
}

class AppUser {
  final int id;
  final String name;
  final String email;
  final UserRole role;

  AppUser({required this.id, required this.name, required this.email, required this.role});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: roleFromString(json['role'] ?? 'customer'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
      };
}
