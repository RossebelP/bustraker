import 'package:latlong2/latlong.dart';

class StopNode {
  const StopNode({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String name;
  final String description;
  final double lat;
  final double lng;

  LatLng get point => LatLng(lat, lng);

  @override
  String toString() => 'StopNode(id: $id, name: $name)';
}
