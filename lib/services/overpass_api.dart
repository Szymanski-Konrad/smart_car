// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/services/firestore_handler.dart';
import 'package:smart_car/utils/logger.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart';

class OverpassApi {
  static const _apiUrl = 'overpass-api.de';
  static const _path = '/api/interpreter';

  /// Fetch gas stations in [radius] m around [center]
  static Future<List<GasStation>> fetchGasStationsAroundCenter(
    QueryLocation center, {
    double radius = 5000,
    Function()? onTimeout,
  }) async {
    final request = Request('GET', Uri.https(_apiUrl, _path));
    final filter = {'amenity': 'fuel'};
    request.bodyFields = _buildRequestBody(center, filter, radius);

    String? responseText;

    try {
      final response =
          await Client().send(request).timeout(const Duration(seconds: 5));

      responseText = await response.stream.bytesToString();
    } on TimeoutException catch (e) {
      Logger.logToFile(e);
      onTimeout?.call();
      return Future.value([]);
    } catch (e) {
      Logger.logToFile(e);
      return Future.value([]);
    }

    var responseJson;

    try {
      responseJson = jsonDecode(responseText);
    } catch (exception) {
      String error = '';
      final document = XmlDocument.parse(responseText);
      final paragraphs = document.findAllElements("p");

      for (var element in paragraphs) {
        if (element.text.trim() != '') {
          error += element.text.trim();
        }
      }

      return Future.error(error);
    }

    if (responseJson['elements'] == null) {
      return [];
    }

    List<ResponseLocation> resultList = [];

    for (var location in responseJson['elements']) {
      resultList.add(ResponseLocation.fromJson(location));
    }

    final stations = await _mapResultsToGasStations(resultList);

    return stations;
  }

  static Map<String, String> _buildRequestBody(
      QueryLocation center, Map<String, String> filter, double radius) {
    final query = OverpassQuery(
      output: 'json',
      timeout: 25,
      elements: [
        SetElement(
          queryType: 'node',
          tags: filter,
          area: LocationArea(
            longitude: center.longitude,
            latitude: center.latitude,
            radius: radius,
          ),
        ),
        SetElement(
          queryType: 'way',
          tags: filter,
          area: LocationArea(
            longitude: center.longitude,
            latitude: center.latitude,
            radius: radius,
          ),
        ),
        SetElement(
          queryType: 'relation',
          tags: filter,
          area: LocationArea(
            longitude: center.longitude,
            latitude: center.latitude,
            radius: radius,
          ),
        ),
      ],
    );

    return query.toMap();
  }

  static Future<List<GasStation>> _mapResultsToGasStations(
    List<ResponseLocation> locations,
  ) async {
    final gasStations = <GasStation>[];
    final ids = locations.map((e) => e.id.toString()).toList();
    final remoteStations = await FirestoreHandler.getAllStations(ids);
    if (remoteStations.length == locations.length) {
      return remoteStations;
    }
    for (final location in locations) {
      final index =
          remoteStations.indexWhere((element) => element.id == location.id);
      if (index >= 0) {
        gasStations.add(remoteStations[index]);
      } else {
        gasStations.add(GasStation.fromLocation(location));
      }
    }

    return gasStations;
  }
}
