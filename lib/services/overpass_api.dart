import 'dart:async';
import 'dart:convert';

import 'package:smart_car/models/overpass/overpass_query.dart';
import 'package:smart_car/utils/logger.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart';

class OverpassApi {
  static const _apiUrl = 'overpass-api.de';
  static const _path = '/api/interpreter';

  static Future<List<ResponseLocation>> fetchGasStationsAroundCenter(
    QueryLocation center,
    Map<String, String> filter,
    double radius,
    Function() onTimeout,
  ) async {
    final request = Request('GET', Uri.https(_apiUrl, _path));
    request.bodyFields = _buildRequestBody(center, filter, radius);

    String? responseText;

    try {
      //TODO: Handle on timeout and other errors
      final response =
          await Client().send(request).timeout(const Duration(seconds: 5));

      responseText = await response.stream.bytesToString();
    } on TimeoutException catch (e) {
      Logger.logToFile(e);
      onTimeout();
      return Future.value([]);
    } catch (e) {
      Logger.logToFile(e);
      return Future.error(e);
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

    return resultList;
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
}
