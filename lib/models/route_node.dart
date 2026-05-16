import 'package:latlong2/latlong.dart';

class RouteNode {
  const RouteNode({required this.lat, required this.lng, this.label = ''});

  final double lat;
  final double lng;
  final String label;

  LatLng get point => LatLng(lat, lng);

  RouteNode copyWith({double? lat, double? lng, String? label}) {
    return RouteNode(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      label: label ?? this.label,
    );
  }

  @override
  String toString() => 'RouteNode(lat: $lat, lng: $lng, label: $label)';
}
