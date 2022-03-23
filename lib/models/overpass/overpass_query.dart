import 'package:latlong2/latlong.dart';
import 'package:smart_car/utils/strings_extension.dart';

class OverpassQuery {
  final String output;
  final int timeout;
  final List<SetElement> elements;

  OverpassQuery({
    required this.output,
    required this.timeout,
    required this.elements,
  });

  Map<String, String> toMap() {
    String elementsString = '';

    for (SetElement element in elements) {
      elementsString += '$element;';
    }

    String data =
        '[out:$output][timeout:$timeout];($elementsString);out center;';

    return <String, String>{'data': data};
  }
}

class SetElement {
  final String queryType; //node, way, relation
  final Map<String, String> tags;
  final LocationArea area;

  SetElement({required this.queryType, required this.tags, required this.area});

  @override
  String toString() {
    String tagString = '';

    tags.forEach((key, value) {
      tagString += '["$key"="$value"]';
    });

    String areaString =
        '(around:${area.radius},${area.latitude},${area.longitude})';

    return '$queryType$tagString$areaString';
  }
}

class LocationArea {
  final double longitude;
  final double latitude;
  final double radius;

  LocationArea({
    required this.longitude,
    required this.latitude,
    required this.radius,
  });
}

class ResponseLocation {
  final int id;
  final double longitude;
  final double latitude;
  final String? name;
  final String? city;
  final String? street;
  final String? openingHours;
  final String? postcode;
  final String? brand;
  final String? stationOperator;
  final String? houseNumber;
  final bool hasLpg;
  final bool hasDiesel;
  final bool hasPb95;
  final bool hasPb98;
  final bool hasShop;
  final bool hasElectricity;

  ResponseLocation({
    required this.id,
    required this.longitude,
    required this.latitude,
    this.name,
    this.city,
    this.street,
    this.houseNumber,
    this.postcode,
    this.openingHours,
    this.stationOperator,
    this.brand,
    this.hasLpg = false,
    this.hasDiesel = false,
    this.hasPb95 = false,
    this.hasPb98 = false,
    this.hasShop = false,
    this.hasElectricity = false,
  });

  static fromJson(Map<dynamic, dynamic> json) {
    final tags = json['tags'];

    if (tags == null) {
      return;
    }

    return ResponseLocation(
      id: json['id'],
      longitude: json['lon'] ?? json['center']['lon'],
      latitude: json['lat'] ?? json['center']['lat'],
      name: json['tags']['name'],
      city: json['tags']['addr:city'],
      street: json['tags']['addr:street'],
      houseNumber: json['tags']['addr:housenumber'],
      postcode: json['tags']['postcode'],
      brand: json['tags']['brand'],
      openingHours: json['tags']['opening_hours'],
      stationOperator: json['tags']['operator'],
      hasLpg: json['tags']['fuel:lpg'].toString().parseBool(),
      hasDiesel: json['tags']['fuel:diesel'].toString().parseBool(),
      hasPb95: json['tags']['fuel:octane_95'].toString().parseBool(),
      hasPb98: json['tags']['fuel:octane_98'].toString().parseBool(),
      hasElectricity: json['tags']['fuel:electricity'].toString().parseBool(),
      hasShop: json['tags']['shop'].toString().parseBool(),
    );
  }
}

class QueryLocation {
  final double longitude;
  final double latitude;

  QueryLocation({
    required this.longitude,
    required this.latitude,
  });

  factory QueryLocation.fromLatLng(LatLng latLng) {
    return QueryLocation(
      longitude: latLng.longitude,
      latitude: latLng.latitude,
    );
  }
}
