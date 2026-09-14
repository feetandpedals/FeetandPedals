class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String imageUrl;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.imageUrl = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'phone': phone,
      };

  AppUser copyWith({String? fullName, String? email, String? phone, String? imageUrl}) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
