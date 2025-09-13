class User {
  final int id;
  final String email;
  final bool isActive;
  final bool isStaff;
  final String? profilePicture;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.isStaff,
    this.profilePicture,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      isActive: json['is_active'] as bool? ?? true,
      isStaff: json['is_staff'] as bool? ?? false,
      profilePicture: json['profile_picture'] as String?,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_active': isActive,
      'is_staff': isStaff,
      'profile_picture': profilePicture,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, isActive: $isActive)';
  }
}
