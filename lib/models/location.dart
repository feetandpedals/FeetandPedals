class EventLocation {
  final String country;
  final String state;
  final String city;
  final String address;
  final String latitude;
  final String longitude;

  const EventLocation({
    this.country = '',
    this.state = '',
    this.city = '',
    this.address = '',
    this.latitude = '',
    this.longitude = '',
  });

  String get displayLine {
    final parts = [city, state, country].where((s) => s.isNotEmpty).join(', ');
    return parts.isNotEmpty ? parts : address;
  }

  factory EventLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EventLocation();
    return EventLocation(
      country: (json['country'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
    );
  }
}
