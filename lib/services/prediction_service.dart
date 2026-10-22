
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'fixture_parser.dart';

class PredictionService {
  // Set this through GitHub Actions using --dart-define.
  static const String endpoint = String.fromEnvironment(
    'PREDICTION_API_URL',
  );

  static Future<Map<String, dynamic>> analyze(
    FixturePair fixture,
  ) async {
    if (endpoint.trim().isEmpty) {
      throw StateError(
        'Prediction backend URL not configured. '
        'Set PREDICTION_API_URL in GitHub Actions.',
      );
    }

    final uri = Uri.parse(
      '${endpoint.replaceAll(RegExp(r"/+$"), "")}/analyze',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'home': fixture.home,
          'away': fixture.away,
        }),
      ).timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Unexpected response from prediction server.',
        );
      }

      if (response.statusCode != 200) {
        throw StateError(
          decoded['error']?.toString() ??
              'Prediction request failed (${response.statusCode}).',
        );
      }

      return decoded;
    } on http.ClientException catch (error) {
      throw StateError(
        'Unable to connect to the prediction server: $error',
      );
    } on FormatException {
      throw StateError(
        'The prediction server returned invalid data.',
      );
    }
  }
}
