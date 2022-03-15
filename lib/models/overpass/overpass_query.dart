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

    String data = '[out:$output][timeout:$timeout];($elementsString);out;';

    return <String, String>{'data': data};
  }
}

class SetElement {
  final Map<String, String> tags;
  final LocationArea area;

  SetElement({required this.tags, required this.area});

  @override
  String toString() {
    String tagString = '';

    tags.forEach((key, value) {
      tagString += '["$key"="$value"]';
    });

    String areaString =
        '(around:${area.radius},${area.latitude},${area.longitude})';

    return 'node$tagString$areaString';
  }
}

class LocationArea {
  final double longitude;
  final double latitude;
  final double radius;

  LocationArea(
      {required this.longitude, required this.latitude, required this.radius});
}

class ResponseLocation {
  final int id;
  final double longitude;
  final double latitude;
  final String? name;
  final String? city;
  final String? street;

  ResponseLocation({
    required this.id,
    required this.longitude,
    required this.latitude,
    this.name,
    this.city,
    this.street,
  });

  static fromJson(Map<dynamic, dynamic> json) {
    final tags = json['tags'];

    if (tags == null) {
      return;
    }

    return ResponseLocation(
      id: json['id'],
      longitude: json['lon'],
      latitude: json['lat'],
      name: json['tags']['name'],
      city: json['tags']['addr:city'],
      street: json['tags']['addr:street'],
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
}
