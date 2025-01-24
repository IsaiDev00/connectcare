// models.dart
class Projection {
  final String name;
  final String imageUrl;

  Projection({required this.name, required this.imageUrl});

  factory Projection.fromJson(Map<String, dynamic> json) {
    return Projection(
      name: json['n'],
      imageUrl: json['i'],
    );
  }
}
