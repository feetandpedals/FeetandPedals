/// A category as returned by `GET /categories` and attached to events
/// (e.g. "Running", "Cycling", "Triathlon", "Walking").
class EventCategoryTag {
  final String id;
  final String name;
  final String imageUrl;

  const EventCategoryTag({required this.id, required this.name, this.imageUrl = ''});

  factory EventCategoryTag.fromJson(Map<String, dynamic> json) {
    return EventCategoryTag(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}
