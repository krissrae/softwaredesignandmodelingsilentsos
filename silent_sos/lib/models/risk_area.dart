class RiskArea {
  final int id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radius;

  RiskArea({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory RiskArea.fromJson(Map<String, dynamic> json) {
    return RiskArea(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      radius: (json['radius'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }

  @override
  String toString() {
    return 'RiskArea(id: $id, name: $name, lat: $latitude, lng: $longitude)';
  }
}
