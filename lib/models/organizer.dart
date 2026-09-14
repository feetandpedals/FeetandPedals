class Organizer {
  final String id;
  final String name;
  final String imageUrl;
  final bool isFollowing;

  const Organizer({this.id = '', this.name = '', this.imageUrl = '', this.isFollowing = false});

  factory Organizer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Organizer();
    return Organizer(
      id: (json['id'] ?? '').toString(),
      name: (json['full_name'] ?? json['name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      isFollowing: json['is_following'] == true,
    );
  }
}
