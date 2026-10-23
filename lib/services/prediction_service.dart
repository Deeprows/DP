import 'dart:convert';

import 'package:http/http.dart' as http;

import 'fixture_parser.dart';

class PredictionService {
  // Keep the existing GitHub Actions --dart-define configuration.
  static const String endpoint = String.fromEnvironment(
    'PREDICTION_API_URL',
  );

  static Uri _uri(String path) {
    if (endpoint.trim().isEmpty) {
      throw StateError(
        'Prediction backend URL not configured. '
        'Set PREDICTION_API_URL in GitHub Actions.',
      );
    }
    return Uri.parse('${endpoint.trim().replaceAll(RegExp(r"/+$"), "")}$path');
  }

  static Future<Map<String, dynamic>> _readResponse(http.Response response) async {
    late final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw StateError('The prediction server returned invalid data.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Unexpected response from prediction server.');
    }
    if (response.statusCode != 200) {
      final message = decoded['message'] ?? decoded['error'] ??
          'Prediction request failed (${response.statusCode}).';
      throw StateError(message.toString());
    }
    if (decoded['status'] == 'error') {
      throw StateError((decoded['message'] ?? 'Prediction unavailable.').toString());
    }
    return decoded;
  }

  // Existing method preserved for the current Analyzer screen.
  // The Worker can return a verified fixture or a prediction depending on
  // its /analyze implementation; never manufacture probabilities here.
  static Future<Map<String, dynamic>> analyze(FixturePair fixture) async {
    try {
      final response = await http.post(
        _uri('/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'home': fixture.home, 'away': fixture.away}),
      ).timeout(const Duration(seconds: 45));
      return await _readResponse(response);
    } on http.ClientException catch (error) {
      throw StateError('Unable to connect to the prediction server: $error');
    }
  }

  // Retrieve real API-Football provider predictions for a known fixture ID.
  // This uses the Cloudflare Worker so the API key stays private.
  static Future<Map<String, dynamic>> predictionsForFixture(int fixtureId) async {
    if (fixtureId <= 0) {
      throw ArgumentError.value(fixtureId, 'fixtureId', 'Must be positive');
    }
    try {
      final response = await http.get(
        _uri('/predictions?fixture=$fixtureId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 45));
      return await _readResponse(response);
    } on http.ClientException catch (error) {
      throw StateError('Unable to connect to the prediction server: $error');
    }
  }

  // Convenience method for the next Analyzer UI update: verify the teams
  // first, then fetch the prediction using the verified fixture ID.
  static Future<Map<String, dynamic>> analyzeWithPrediction(
    FixturePair fixture,
  ) async {
    final verified = await analyze(fixture);
    final status = verified['status']?.toString();
    if (status != 'found' && status != 'ok') return verified;

    final rawFixture = verified['fixture'];
    if (rawFixture is! Map) return verified;
    final rawId = rawFixture['id'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
    if (id == null || id <= 0) return verified;

    final result = await predictionsForFixture(id);
    return {
      ...verified,
      'predictionStatus': result['status'],
      'prediction': result['prediction'],
      'predictionMessage': result['message'],
      'predictionSource': result['source'],
      'predictionModel': result['model'],
    };
  }
}
